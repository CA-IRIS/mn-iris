/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2016-2018  Minnesota Department of Transportation
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

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import us.mn.state.dot.tms.ChangeVetoException;
import us.mn.state.dot.tms.EventType;
import us.mn.state.dot.tms.IncDescriptor;
import us.mn.state.dot.tms.IncidentDetail;
import us.mn.state.dot.tms.LaneType;
import us.mn.state.dot.tms.SignGroup;
import us.mn.state.dot.tms.TMSException;
import us.mn.state.dot.tms.utils.MultiString;

/**
 * An incident descriptor is part of a message to deploy on a DMS, matching
 * incident attributes.
 *
 * @author Douglas Lau
 */
public class IncDescriptorImpl extends BaseObjectImpl implements IncDescriptor {

	/** Load all the incident descriptors */
	static protected void loadAll() throws TMSException {
		namespace.registerType(SONAR_TYPE, IncDescriptorImpl.class);
		store.query("SELECT name, event_desc_id, lane_type, detail, " +
			"cleared, multi, abbrev FROM iris." + SONAR_TYPE + ";",
			new ResultFactory()
		{
			public void create(ResultSet row) throws Exception {
				namespace.addObject(new IncDescriptorImpl(row));
			}
		});
	}

	/** Get a mapping of the columns */
	@Override
	public Map<String, Object> getColumns() {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("name", name);
		map.put("event_desc_id", event_desc_id);
		map.put("lane_type", lane_type);
		map.put("detail", detail);
		map.put("cleared", cleared);
		map.put("multi", multi);
		map.put("abbrev", abbrev);
		return map;
	}

	/** Get the database table name */
	@Override
	public String getTable() {
		return "iris." + SONAR_TYPE;
	}

	/** Get the SONAR type name */
	@Override
	public String getTypeName() {
		return SONAR_TYPE;
	}

	/** Create an incident descriptor */
	private IncDescriptorImpl(ResultSet row) throws SQLException {
		this(row.getString(1),          // name
		     row.getInt(2),             // event_desc_id
		     row.getShort(3),           // lane_type
		     row.getString(4),          // detail
		     row.getBoolean(5),         // cleared
		     row.getString(6),          // multi
		     row.getString(7)           // abbrev
		);
	}

	/** Create an incident descriptor */
	private IncDescriptorImpl(String n, int et, short lt, String dtl,
		boolean c, String m, String a)
	{
		super(n);
		event_desc_id = et;
		lane_type = lt;
		detail = lookupIncDetail(dtl);
		cleared = c;
		multi = m;
		abbrev = a;
	}

	/** Create a new incident descriptor */
	public IncDescriptorImpl(String n) {
		super(n);
	}

	/** Event type (id of EventType enum) */
	private int event_desc_id;

	/** Set the event type */
	@Override
	public void setEventType(int et) {
		event_desc_id = et;
	}

	/** Set the event type */
	public void doSetEventType(int et) throws TMSException {
		checkEventType(et);
		if (et != event_desc_id) {
			store.update(this, "event_desc_id", et);
			setEventType(et);
		}
	}

	/** Check for valid event types */
	private void checkEventType(int et) throws ChangeVetoException {
		switch (EventType.fromId(et)) {
		case INCIDENT_CRASH:
		case INCIDENT_STALL:
		case INCIDENT_ROADWORK:
		case INCIDENT_HAZARD:
			return;
		default:
			throw new ChangeVetoException("INVALID EVENT TYPE");
		}
	}

	/** Get the event type */
	@Override
	public int getEventType() {
		return event_desc_id;
	}

	/** Lane type ordinal */
	private short lane_type = (short) LaneType.MAINLINE.ordinal();

	/** Set the lane type ordinal */
	@Override
	public void setLaneType(short lt) {
		lane_type = lt;
	}

	/** Set the lane type ordinal */
	public void doSetLaneType(short lt) throws TMSException {
		checkLaneType(lt);
		if (lt != lane_type) {
			store.update(this, "lane_type", lt);
			setLaneType(lt);
		}
	}

	/** Check for valid lane types */
	private void checkLaneType(short lt) throws ChangeVetoException {
		switch (LaneType.fromOrdinal(lt)) {
		case MAINLINE:
		case EXIT:
		case MERGE:
		case CD_LANE:
			return;
		default:
			throw new ChangeVetoException("INVALID LANE TYPE");
		}
	}

	/** Get the lane type ordinal */
	@Override
	public short getLaneType() {
		return lane_type;
	}

	/** Incident detail */
	private IncidentDetail detail;

	/** Set the incident detail */
	@Override
	public void setDetail(IncidentDetail dtl) {
		detail = dtl;
	}

	/** Set the incident detail */
	public void doSetDetail(IncidentDetail dtl) throws TMSException {
		if (dtl != detail) {
			store.update(this, "detail", dtl);
			setDetail(dtl);
		}
	}

	/** Get the incident detail */
	@Override
	public IncidentDetail getDetail() {
		return detail;
	}

	/** Incident cleared status */
	private boolean cleared = false;

	/** Set the cleared status */
	@Override
	public void setCleared(boolean c) {
		cleared = c;
	}

	/** Set the cleared status */
	public void doSetCleared(boolean c) throws TMSException {
		if (c != cleared) {
			store.update(this, "cleared", c);
			setCleared(c);
		}
	}

	/** Get the cleared status */
	@Override
	public boolean getCleared() {
		return cleared;
	}

	/** MULTI string */
	private String multi = "";

	/** Set the MULTI string */
	@Override
	public void setMulti(String m) {
		multi = m;
	}

	/** Set the MULTI string */
	public void doSetMulti(String m) throws TMSException {
		// FIXME: only allow true MULTI tags here
		if (!new MultiString(m).isValid())
			throw new ChangeVetoException("Invalid MULTI: " + m);
		if (!m.equals(multi)) {
			store.update(this, "multi", m);
			setMulti(m);
		}
	}

	/** Get the MULTI string */
	@Override
	public String getMulti() {
		return multi;
	}

	/** Abbreviated MULTI string */
	private String abbrev;

	/** Set abbreviated MULTI string */
	@Override
	public void setAbbrev(String a) {
		abbrev = a;
	}

	/** Set abbreviated MULTI string */
	public void doSetAbbrev(String a) throws TMSException {
		// FIXME: only allow true MULTI tags here
		if (a != null && !new MultiString(a).isValid())
			throw new ChangeVetoException("Invalid MULTI: " + a);
		if (!objectEquals(a, abbrev)) {
			store.update(this, "abbrev", a);
			setAbbrev(a);
		}
	}

	/** Get abbreviated MULTI string */
	@Override
	public String getAbbrev() {
		return abbrev;
	}
}
