/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2000-2012  Minnesota Department of Transportation
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */
package us.mn.state.dot.tms.server;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.util.Calendar;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import us.mn.state.dot.geokit.Position;
import us.mn.state.dot.sched.TimeSteward;
import us.mn.state.dot.sonar.Checker;
import us.mn.state.dot.sonar.Namespace;
import us.mn.state.dot.sonar.SonarException;
import us.mn.state.dot.tms.ActionPlan;
import us.mn.state.dot.tms.Camera;
import us.mn.state.dot.tms.ChangeVetoException;
import static us.mn.state.dot.tms.Constants.MISSING_DATA;
import us.mn.state.dot.tms.Controller;
import us.mn.state.dot.tms.Detector;
import us.mn.state.dot.tms.DeviceRequest;
import us.mn.state.dot.tms.GeoLoc;
import us.mn.state.dot.tms.GeoLocHelper;
import us.mn.state.dot.tms.LaneType;
import us.mn.state.dot.tms.MeterAction;
import us.mn.state.dot.tms.MeterActionHelper;
import us.mn.state.dot.tms.MeterAlgorithm;
import us.mn.state.dot.tms.R_Node;
import us.mn.state.dot.tms.R_NodeType;
import us.mn.state.dot.tms.RampMeter;
import us.mn.state.dot.tms.RampMeterLock;
import us.mn.state.dot.tms.RampMeterQueue;
import us.mn.state.dot.tms.RampMeterType;
import us.mn.state.dot.tms.SystemAttributeHelper;
import us.mn.state.dot.tms.TimeAction;
import us.mn.state.dot.tms.TimeActionHelper;
import us.mn.state.dot.tms.TMSException;
import us.mn.state.dot.tms.server.comm.MessagePoller;
import us.mn.state.dot.tms.server.comm.MeterPoller;

/**
 * A ramp meter is a traffic signal which meters the flow of traffic on a
 * freeway entrance ramp.
 *
 * @author Douglas Lau
 */
public class RampMeterImpl extends DeviceImpl implements RampMeter {

	/** Ordinal value for lock "OFF" */
	static protected final Integer OFF_ORDINAL =
		new Integer(RampMeterLock.OFF.ordinal());

	/** Default maximum wait time (in seconds) */
	static public final int DEFAULT_MAX_WAIT = 240;

	/** Meter debug log */
	static protected final IDebugLog METER_LOG = new IDebugLog("meter");

	/** Filter a releae rate for valid range */
	static protected int filterRate(int r) {
		r = Math.max(r, SystemAttributeHelper.getMeterMinRelease());
		return Math.min(r, SystemAttributeHelper.getMeterMaxRelease());
	}

	/** Calculate the minimum of two (possibly null) integers */
	static protected Integer minimum(Integer r0, Integer r1) {
		if(r0 == null)
			return r1;
		if(r1 == null)
			return r0;
		return Math.min(r0, r1);
	}

	/** Get the current AM/PM period */
	static protected int currentPeriod() {
		return TimeSteward.getCalendarInstance().get(Calendar.AM_PM);
	}

	/** Load all the ramp meters */
	static protected void loadAll() throws TMSException {
		System.err.println("Loading ramp meters...");
		namespace.registerType(SONAR_TYPE, RampMeterImpl.class);
		store.query("SELECT name, geo_loc, controller, pin, notes, " +
			"meter_type, storage, max_wait, algorithm, am_target, "+
			"pm_target, camera, m_lock FROM iris." + SONAR_TYPE +
			";", new ResultFactory()
		{
			public void create(ResultSet row) throws Exception {
				namespace.addObject(new RampMeterImpl(namespace,
					row.getString(1),	// name
					row.getString(2),	// geo_loc
					row.getString(3),	// controller
					row.getInt(4),		// pin
					row.getString(5),	// notes
					row.getInt(6),		// meter_type
					row.getInt(7),		// storage
					row.getInt(8),		// max_wait
					row.getInt(9),		// algorithm
					row.getInt(10),		// am_target
					row.getInt(11),		// pm_target
					row.getString(12),	// camera
					row.getInt(13)		// m_lock
				));
			}
		});
	}

	/** Get a mapping of the columns */
	public Map<String, Object> getColumns() {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("name", name);
		map.put("geo_loc", geo_loc);
		map.put("controller", controller);
		map.put("pin", pin);
		map.put("notes", notes);
		map.put("meter_type", meter_type.ordinal());
		map.put("storage", storage);
		map.put("max_wait", max_wait);
		map.put("algorithm", algorithm);
		map.put("am_target", am_target);
		map.put("pm_target", pm_target);
		map.put("camera", camera);
		if(m_lock != null)
			map.put("m_lock", m_lock.ordinal());
		return map;
	}

	/** Get the database table name */
	public String getTable() {
		return "iris." + SONAR_TYPE;
	}

	/** Get the SONAR type name */
	public String getTypeName() {
		return SONAR_TYPE;
	}

	/** Create a new ramp meter with a string name */
	public RampMeterImpl(String n) throws TMSException, SonarException {
		super(n);
		GeoLocImpl g = new GeoLocImpl(name);
		MainServer.server.createObject(g);
		geo_loc = g;
	}

	/** Create a ramp meter */
	protected RampMeterImpl(String n, GeoLocImpl loc, ControllerImpl c,
		int p, String nt, int t, int st, int w, int alg, int at, int pt,
		Camera cam, Integer lk)
	{
		super(n, c, p, nt);
		geo_loc = loc;
		meter_type = RampMeterType.fromOrdinal(t);
		storage = st;
		max_wait = w;
		camera = cam;
		algorithm = alg;
		am_target = at;
		pm_target = pt;
		m_lock = RampMeterLock.fromOrdinal(lk);
		rate = null;
		initTransients();
	}

	/** Create a ramp meter */
	protected RampMeterImpl(Namespace ns, String n, String loc, String c,
		int p, String nt, int t, int st, int w, int alg, int at, int pt,
		String cam, Integer lk)
	{
		this(n, (GeoLocImpl)ns.lookupObject(GeoLoc.SONAR_TYPE, loc),
		     (ControllerImpl)ns.lookupObject(Controller.SONAR_TYPE, c),
		     p, nt, t, st, w, alg, at, pt,
		     (Camera)ns.lookupObject(Camera.SONAR_TYPE, cam), lk);
	}

	/** Initialize the transient state */
	public void initTransients() {
		super.initTransients();
		lookupGreenDetector();
	}

	/** Destroy an object */
	public void doDestroy() throws TMSException {
		super.doDestroy();
		MainServer.server.removeObject(geo_loc);
	}

	/** Device location */
	protected GeoLocImpl geo_loc;

	/** Get the device location */
	public GeoLoc getGeoLoc() {
		return geo_loc;
	}

	/** Ramp meter type */
	protected RampMeterType meter_type = RampMeterType.DUAL_ALTERNATE;

	/** Set ramp meter type */
	public void setMeterType(int t) {
		meter_type = RampMeterType.fromOrdinal(t);
	}

	/** Set the ramp meter type */
	public void doSetMeterType(int t) throws TMSException {
		if(t == meter_type.ordinal())
			return;
		store.update(this, "meter_type", t);
		setMeterType(t);
	}

	/** Get the ramp meter type */
	public int getMeterType() {
		return meter_type.ordinal();
	}

	/** Queue storage length (in feet) */
	protected int storage = 1;

	/** Set the queue storage length (in feet) */
	public void setStorage(int s) {
		storage = s;
	}

	/** Set the queue storage length (in feet) */
	public void doSetStorage(int s) throws TMSException {
		if(s == storage)
			return;
		if(s < 1)
			throw new ChangeVetoException("Storage must be > 0");
		store.update(this, "storage", s);
		setStorage(s);
	}

	/** Get the queue storage length (in feet) */
	public int getStorage() {
		return storage;
	}

	/** Maximum allowed meter wait time (in seconds) */
	protected int max_wait = DEFAULT_MAX_WAIT;

	/** Set the maximum allowed meter wait time (in seconds) */
	public void setMaxWait(int w) {
		max_wait = w;
	}

	/** Set the maximum allowed meter wait time (in seconds) */
	public void doSetMaxWait(int w) throws TMSException {
		if(w == max_wait)
			return;
		if(w < 1)
			throw new ChangeVetoException("Wait must be > 0");
		store.update(this, "max_wait", w);
		setMaxWait(w);
	}

	/** Get the maximum allowed meter wait time (in seconds) */
	public int getMaxWait() {
		return max_wait;
	}

	/** Ordinal of meter algorithm enumeration */
	private int algorithm;

	/** Set the metering algorithm */
	public void setAlgorithm(int a) {
		algorithm = a;
	}

	/** Set the metering algorithm */
	public void doSetAlgorithm(int a) throws TMSException {
		int alg = MeterAlgorithm.fromOrdinal(a).ordinal();
		if(alg == algorithm)
			return;
		store.update(this, "algorithm", alg);
		setAlgorithm(alg);
		// FIXME
		alg_state = null;
	}

	/** Get the metering algorithm */
	public int getAlgorithm() {
		return algorithm;
	}

	/** AM target rate */
	private int am_target;

	/** Set the AM target rate */
	public void setAmTarget(int t) {
		am_target = t;
	}

	/** Set the AM target rate */
	public void doSetAmTarget(int t) throws TMSException {
		if(t == am_target)
			return;
		store.update(this, "am_target", t);
		setAmTarget(t);
	}

	/** Get the AM target rate */
	public int getAmTarget() {
		return am_target;
	}

	/** PM target rate */
	private int pm_target;

	/** Set the PM target rate */
	public void setPmTarget(int t) {
		pm_target = t;
	}

	/** Set the PM target rate */
	public void doSetPmTarget(int t) throws TMSException {
		if(t == pm_target)
			return;
		store.update(this, "pm_target", t);
		setPmTarget(t);
	}

	/** Get the PM target rate */
	public int getPmTarget() {
		return pm_target;
	}

	/** Get the target rate for current period */
	public int getTarget() {
		if(currentPeriod() == Calendar.AM)
			return getAmTarget();
		else
			return getPmTarget();
	}

	/** Get the start minute for current period */
	public int getStartMin() {
		return getTimeActionMinute(true);
	}

	/** Get the stop minute for current period */
	public int getStopMin() {
		return getTimeActionMinute(false);
	}

	/** Get the minute for a matching time action */
	private int getTimeActionMinute(final boolean start) {
		final int period = currentPeriod();
		final LinkedList<MeterAction> act = getMeterActions();
		TimeAction t = TimeActionHelper.find(new Checker<TimeAction>() {
			public boolean check(TimeAction ta) {
				if(TimeActionHelper.getPeriod(ta) == period)
					return checkTimeAction(ta, start, act);
				else
					return false;
			}
		});
		if(t != null)
			return TimeActionHelper.getMinute(t);
		else
			return TimeActionHelper.NOON;
	}

	/** Get a list of all meter actions which control the meter */
	private LinkedList<MeterAction> getMeterActions() {
		final RampMeterImpl meter = this;
		final LinkedList<MeterAction> act =
			new LinkedList<MeterAction>();
		MeterActionHelper.find(new Checker<MeterAction>() {
			public boolean check(MeterAction ma) {
				if(ma.getRampMeter() == meter) {
					ActionPlan ap = ma.getActionPlan();
					if(ap.getActive())
						act.add(ma);
				}
				return false;
			}
		});
		return act;
	}

	/** Check a time action */
	private boolean checkTimeAction(TimeAction ta, boolean start,
		LinkedList<MeterAction> act)
	{
		for(MeterAction ma: act) {
			if(ta.getActionPlan() == ma.getActionPlan()) {
				boolean deploy = ta.getPhase() == ma.getPhase();
				if(deploy == start)
					return true;
			}
		}
		return false;
	}

	/** Camera from which this can be seen */
	protected Camera camera;

	/** Set the verification camera */
	public void setCamera(Camera c) {
		camera = c;
	}

	/** Set the verification camera */
	public void doSetCamera(Camera c) throws TMSException {
		if(c == camera)
			return;
		store.update(this, "camera", c);
		setCamera(c);
	}

	/** Get verification camera */
	public Camera getCamera() {
		return camera;
	}

	/** Metering rate lock status */
	protected RampMeterLock m_lock = null;

	/** Set the ramp meter lock status */
	public void setMLock(Integer l) {
		m_lock = RampMeterLock.fromOrdinal(l);
	}

	/** Set the ramp meter lock (update) */
	protected void setMLock(RampMeterLock l) throws TMSException {
		if(l == m_lock)
			return;
		if(l != null)
			store.update(this, "m_lock", l.ordinal());
		else
			store.update(this, "m_lock", null);
		m_lock = l;
	}

	/** Set the ramp meter lock status */
	public void doSetMLock(Integer l) throws TMSException {
		if(RampMeterLock.isControllerLock(l) || OFF_ORDINAL.equals(l))
			throw new ChangeVetoException("Invalid lock value");
		setMLock(RampMeterLock.fromOrdinal(l));
	}

	/** Get the ramp meter lock status */
	public Integer getMLock() {
		if(m_lock != null)
			return m_lock.ordinal();
		else
			return null;
	}

	/** Is the metering rate locked? */
	public boolean isLocked() {
		return m_lock != null;
	}

	/** Set the status of the police panel switch */
	public void setPolicePanel(boolean p) {
		try {
			_setPolicePanel(p);
		}
		catch(TMSException e) {
			e.printStackTrace();
		}
	}

	/** Set the status of the police panel switch */
	protected void _setPolicePanel(boolean p) throws TMSException {
		if(p) {
			if(m_lock == null) {
				setMLock(RampMeterLock.POLICE_PANEL);
				notifyAttribute("mLock");
			}
		} else {
			if(m_lock == RampMeterLock.POLICE_PANEL) {
				setMLock((RampMeterLock)null);
				notifyAttribute("mLock");
			}
		}
	}

	/** Set the status of manual metering */
	public void setManual(boolean m) {
		try {
			_setManual(m);
		}
		catch(TMSException e) {
			e.printStackTrace();
		}
	}

	/** Set the status of manual metering */
	protected void _setManual(boolean m) throws TMSException {
		if(m) {
			if(m_lock == null) {
				setMLock(RampMeterLock.MANUAL);
				notifyAttribute("mLock");
			}
		} else {
			if(m_lock == RampMeterLock.MANUAL) {
				setMLock((RampMeterLock)null);
				notifyAttribute("mLock");
			}
		}
	}

	/** Get the meter poller */
	protected MeterPoller getMeterPoller() {
		if(isActive()) {
			MessagePoller p = getPoller();
			if(p instanceof MeterPoller)
				return (MeterPoller)p;
		}
		return null;
	}

	/** Request a device operation */
	public void setDeviceRequest(int r) {
		MeterPoller p = getMeterPoller();
		if(p != null)
			p.sendRequest(this, DeviceRequest.fromOrdinal(r));
	}

	/** Metering algorithm state */
	private transient MeterAlgorithmState alg_state;

	/** Set the algorithm operating state */
	public void setOperating(boolean o) {
		if(o) {
			if(alg_state == null)
				alg_state = createState();
		} else
			alg_state = null;
	}

	/** Get the algorithm operating state */
	public boolean isOperating() {
		return alg_state != null;
	}

	/** Create the meter algorithm state */
	private MeterAlgorithmState createState() {
		switch(MeterAlgorithm.fromOrdinal(algorithm)) {
		case SIMPLE:
			return new SimpleAlgorithm();
		case STRATIFIED:
			return lookupOrCreateStratified();
		case K_ADAPTIVE:
			return lookupOrCreateKAdaptive();
		default:
			return null;
		}
	}

	/** Lookup or create a stratified algorithm state */
	protected MeterAlgorithmState lookupOrCreateStratified() {
		Corridor c = getCorridor();
		if(c != null)
			return StratifiedAlgorithm.lookupCorridor(c);
		else
			return null;
	}

	/** Lookup or create a K adaptive algorithm state */
	protected MeterAlgorithmState lookupOrCreateKAdaptive() {
		Corridor c = getCorridor();
		if(c != null)
			return KAdaptiveAlgorithm.lookupCorridor(c);
		else
			return null;
	}

	/** Validate the metering algorithm */
	public void validateAlgorithm() {
		MeterAlgorithmState s = alg_state;
		if(s != null)
			s.validate(this);
	}

	/** Ramp meter queue status */
	protected RampMeterQueue queue = RampMeterQueue.UNKNOWN;

	/** Set the queue status */
	protected void setQueue(RampMeterQueue q) {
		if(isFailed())
			queue = RampMeterQueue.UNKNOWN;
		else if(isMetering())
			queue = q;
		else
			queue = RampMeterQueue.EMPTY;
		notifyAttribute("queue");
	}

	/** Get the queue status */
	public int getQueue() {
		return queue.ordinal();
	}

	/** Is the ramp meter currently metering? */
	public boolean isMetering() {
		return rate != null;
	}

	/** Planned next release rate */
	protected transient Integer ratePlanned = null;

	/** Set the planned next release rate */
	public void setRatePlanned(Integer r) {
		Integer rp = ratePlanned;
		if(r != null && rp != null)
			ratePlanned = Math.min(rp, r);
		else
			ratePlanned = r;
	}

	/** Update the planned rate */
	public void updateRatePlanned() {
		if(!isLocked())
			setRateNext(ratePlanned);
		setRatePlanned(null);
	}

	/** Release rate (vehicles per hour) */
	protected transient Integer rate = null;

	/** Set the release rate (vehicles per hour) */
	public void setRateNext(Integer r) {
		MeterPoller mp = getMeterPoller();
		if(mp != null) {
			if(r != null)
				r = filterRate(Math.max(r, getMinimum()));
			mp.sendReleaseRate(this, r);
		}
	}

	/** Set the release rate (and notify clients) */
	public void setRateNotify(Integer r) {
		if(rateChanged(r)) {
			rate = r;
			notifyAttribute("rate");
		}
	}

	/** Test if the release rate has changed */
	protected boolean rateChanged(Integer r) {
		if(r == null)
			return rate != null;
		else
			return !r.equals(rate);
	}

	/** Get the release rate (vehciels per hour) */
	public Integer getRate() {
		return rate;
	}

	/** Get the minimum release rate (vehicles per hour) */
	protected int getMinimum() {
		if(isFailed())
			return SystemAttributeHelper.getMeterMaxRelease();
		else
			return SystemAttributeHelper.getMeterMinRelease();
	}

	/** Get the detector set associated with the ramp meter */
	public DetectorSet getDetectorSet() {
		final DetectorSet ds = new DetectorSet();
		Corridor.NodeFinder finder = new Corridor.NodeFinder() {
			public boolean check(R_NodeImpl n) {
				if(n.getNodeType() ==
					R_NodeType.ENTRANCE.ordinal())
				{
					GeoLoc l = n.getGeoLoc();
					if(GeoLocHelper.matchesRoot(l, geo_loc))
					{
						ds.addDetectors(
							n.getDetectorSet());
					}
				}
				return false;
			}
		};
		Corridor corridor = getCorridor();
		if(corridor != null) {
			corridor.findActiveNode(finder);
			String cd = corridor.getLinkedCDRoad();
			if(cd != null) {
				Corridor cd_road = corridors.getCorridor(cd);
				if(cd_road != null)
					cd_road.findActiveNode(finder);
			}
		}
		return ds;
	}

	/** Get the detectors associated with the ramp meter */
	public Detector[] getDetectors() {
		DetectorImpl[] dets = getDetectorSet().toArray();
		Detector[] ds = new Detector[dets.length];
		for(int i = 0; i < dets.length; i++)
			ds[i] = dets[i];
		return ds;
	}

	/** Green count detector */
	protected transient DetectorImpl green_det = null;

	/** Lookup the green count detector */
	protected void lookupGreenDetector() {
		DetectorImpl[] g = getDetectorSet().getDetectorSet(
			LaneType.GREEN).toArray();
		if(g.length > 0)
			green_det = g[0];
		else
			green_det = null;
	}

	/** Update the 30-second green count */
	public void updateGreenCount(long stamp, int g) {
		DetectorImpl det = green_det;
		if(det != null) {
			if(g == 0 && isMetering())
				return;
			det.storeData30Second(stamp, g, MISSING_DATA);
		} else
			METER_LOG.log("No green det for " + getName());
	}

	/** Update the 5-minute green count */
	public void updateGreenCount5(long stamp, int g) {
		DetectorImpl det = green_det;
		if(det != null)
			det.storeData5Minute(stamp, g, MISSING_DATA);
		else
			METER_LOG.log("No green det for " + getName());
	}

	/** Get the corridor containing the ramp meter */
	public Corridor getCorridor() {
		String cid = GeoLocHelper.getCorridorName(geo_loc);
		return corridors.getCorridor(cid);
	}

	/** Print meter as an XML element */
	public void printXml(PrintWriter out) {
		out.print("<meter");
		out.print(XmlWriter.createAttribute("name", getName()));
		Position pos = GeoLocHelper.getWgs84Position(geo_loc);
		if(pos != null) {
			out.print(XmlWriter.createAttribute("lon",
				formatDouble(pos.getLongitude())));
			out.print(XmlWriter.createAttribute("lat",
				formatDouble(pos.getLatitude())));
		}
		out.print(" storage='" + getStorage() + "'");
		int w = getMaxWait();
		if(w != DEFAULT_MAX_WAIT)
			out.print(" max_wait='" + w + "'");
		out.println("/>");
	}

	/** Get the r_node associated with the ramp meter */
	public R_NodeImpl getR_Node() {
		lookupGreenDetector();
		DetectorImpl det = green_det;
		if(det != null) {
			R_Node n = det.getR_Node();
			if(n instanceof R_NodeImpl)
				return (R_NodeImpl)n;
		}
		return null;
	}

	/** Get the number of milliseconds the meter has been failed */
	public long getFailMillis() {
		ControllerImpl c = controller;	// Avoid race
		if(c != null)
			return c.getFailMillis();
		else
			return Long.MAX_VALUE;
	}
}
