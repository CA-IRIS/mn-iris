/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2000-2011  Minnesota Department of Transportation
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
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;
import us.mn.state.dot.tms.ChangeVetoException;
import us.mn.state.dot.tms.CommLink;
import us.mn.state.dot.tms.CommProtocol;
import us.mn.state.dot.tms.Constants;
import us.mn.state.dot.tms.Controller;
import us.mn.state.dot.tms.TMSException;
import us.mn.state.dot.tms.server.comm.MessagePoller;
import us.mn.state.dot.tms.server.comm.Operation;

/**
 * The CommLinkImpl class represents a single communication link which is
 * connected with one or more field device controllers. Many different
 * protocols are supported, including Mn/DOT's 4- and 5-bit 170 protocols,
 * NTCIP class B, Wavetronix SmartSensor, and 3M Canoga.
 *
 * @author Douglas Lau
 */
public class CommLinkImpl extends BaseObjectImpl implements CommLink {

	/** Load all the comm links */
	static protected void loadAll() throws TMSException {
		System.err.println("Loading comm links...");
		namespace.registerType(SONAR_TYPE, CommLinkImpl.class);
		store.query("SELECT name, description, url, protocol, " +
			"timeout FROM iris." + SONAR_TYPE  + ";",
			new ResultFactory()
		{
			public void create(ResultSet row) throws Exception {
				namespace.addObject(new CommLinkImpl(
					row.getString(1),	// name
					row.getString(2),	// description
					row.getString(3),	// url
					row.getShort(4),	// protocol
					row.getInt(5)		// timeout
				));
			}
		});
	}

	/** Get a mapping of the columns */
	public Map<String, Object> getColumns() {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("name", name);
		map.put("description", description);
		map.put("url", url);
		map.put("protocol", (short)protocol.ordinal());
		map.put("timeout", timeout);
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

	/** Create a new comm link */
	public CommLinkImpl(String n) {
		super(n);
	}

	/** Create a new comm link */
	public CommLinkImpl(String n, String d, String u, short p, int t) {
		super(n);
		description = d;
		url = u;
		CommProtocol cp = CommProtocol.fromOrdinal(p);
		if(cp != null)
			protocol = cp;
		timeout = t;
		poller = null;
	}

	/** Destroy an object */
	public void doDestroy() throws TMSException {
		closePoller();
		super.doDestroy();
	}

	/** Description of communication link */
	protected String description = "<New Link>";

	/** Set text description */
	public void setDescription(String d) {
		description = d;
	}

	/** Set text description */
	public void doSetDescription(String d) throws TMSException {
		if(d.equals(description))
			return;
		store.update(this, "description", d);
		setDescription(d);
	}

	/** Get text description */
	public String getDescription() {
		return description;
	}

	/** Remote URL for link */
	protected String url = "";

	/** Set remote URL for link */
	public void setUrl(String u) {
		url = u;
	}

	/** Set remote URL for link */
	public void doSetUrl(String u) throws TMSException {
		if(u.equals(url))
			return;
		store.update(this, "url", u);
		setUrl(u);
		closePoller();
	}

	/** Get remote URL for link */
	public String getUrl() {
		return url;
	}

	/** Communication protocol */
	protected CommProtocol protocol = CommProtocol.NTCIP_C;

	/** Set the communication protocol */
	public void setProtocol(short p) {
		CommProtocol cp = CommProtocol.fromOrdinal(p);
		if(cp != null)
			protocol = cp;
	}

	/** Set the communication protocol */
	public void doSetProtocol(short p) throws TMSException {
		CommProtocol cp = CommProtocol.fromOrdinal(p);
		if(cp == null)
			throw new ChangeVetoException("Invalid protocol: " + p);
		if(cp == protocol)
			return;
		store.update(this, "protocol", p);
		setProtocol(p);
		closePoller();
	}

	/** Get the communication protocol */
	public short getProtocol() {
		return (short)protocol.ordinal();
	}

	/** Polling timeout (milliseconds) */
	protected int timeout = 750;

	/** Set the polling timeout (milliseconds) */
	public void setTimeout(int t) {
		timeout = t;
	}

	/** Set the polling timeout (milliseconds) */
	public void doSetTimeout(int t) throws TMSException {
		if(t == timeout)
			return;
		try {
			MessagePoller p = poller;
			if(p != null)
				p.setTimeout(t);
		}
		catch(IOException e) {
			throw new TMSException(e);
		}
		store.update(this, "timeout", t);
		setTimeout(t);
	}

	/** Get the polling timeout (milliseconds) */
	public int getTimeout() {
		return timeout;
	}

	/** Message poller for communication */
	protected transient MessagePoller poller;

	/** Get the message poller.  This must be synchronized to protect
	 * access to the poller member variable. */
	public synchronized MessagePoller getPoller() {
		if(poller != null) {
			setStatus(poller.getStatus());
			if(poller.isAlive())
				return poller;
			else
				closePoller();
		}
		return openPoller();
	}

	/** Open the message poller.  Poller must be null prior to calling. */
	protected synchronized MessagePoller openPoller() {
		assert poller == null;
		try {
			poller = MessagePoller.create(name, protocol, url);
			poller.setTimeout(timeout);
			poller.start();
		}
		catch(IOException e) {
			closePoller();
			setStatus("I/O error: " + e.getMessage());
		}
		return poller;
	}

	/** Close the message poller */
	protected synchronized void closePoller() {
		failControllers();
		if(poller != null)
			poller.stopPolling();
		poller = null;
	}

	/** Communication link status */
	protected transient String status = Constants.UNKNOWN;

	/** Set the communication status */
	public void setStatus(String s) {
		if(s == null || s.equals(status))
			return;
		status = s;
		notifyAttribute("status");
	}

	/** Get the communication status */
	public String getStatus() {
		return status;
	}

	/** Field device controllers */
	protected transient final TreeMap<Integer, ControllerImpl> controllers =
		new TreeMap<Integer, ControllerImpl>();

	/** Put a controller on the link */
	public void putController(int d, ControllerImpl c)
		throws ChangeVetoException
	{
		synchronized(controllers) {
			if(controllers.containsKey(d)) {
				throw new ChangeVetoException("Drop " + d +
					" exists");
			}
			controllers.put(d, c);
		}
	}

	/** Pull a controller from the link */
	public void pullController(ControllerImpl c) {
		Integer d = new Integer(c.getDrop());
		synchronized(controllers) {
			controllers.remove(d);
		}
	}

	/** Get a controller by drop */
	public Controller getController(short drop) {
		Integer d = new Integer(drop);
		synchronized(controllers) {
			return controllers.get(d);
		}
	}

	/** Get the controllers defined for this communication link */
	public Controller[] getControllers() {
		synchronized(controllers) {
			return (Controller [])controllers.values().toArray(
				new Controller[0]);
		}
	}

	/** Find the controller */
	public ControllerImpl findController(Controller c) {
		synchronized(controllers) {
			for(ControllerImpl cont: controllers.values()) {
				if(cont.equals(c))
					return cont;
			}
			return null;
		}
	}

	/** Set all controllers to a failed status */
	protected void failControllers() {
		synchronized(controllers) {
			for(ControllerImpl c: controllers.values()) {
				c.setFailed(true);
			}
		}
	}

	/** Add an operation to the communication link */
	void addOperation(Operation o) {
		MessagePoller p = getPoller();
		if(p != null)
			p.addOperation(o);
	}

	/** Line load */
	protected transient float load;

	/** Get the current link load */
	public float getLoad() {
		return load;
	}
}
