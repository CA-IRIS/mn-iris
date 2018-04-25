/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2017-2018  Minnesota Department of Transportation
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
package us.mn.state.dot.tms.server.comm.monstream;

import java.io.IOException;
import java.nio.ByteBuffer;
import us.mn.state.dot.tms.server.comm.Operation;

/**
 * A property to configure a monitor.
 *
 * @author Douglas Lau
 */
public class ConfigProp extends MonProp {

	/** Maximum pin number */
	private final int max_pin;

	/** Create a new config property */
	public ConfigProp(int p) {
		max_pin = p;
	}

	/** Encode a STORE request */
	@Override
	public void encodeStore(Operation op, ByteBuffer tx_buf)
		throws IOException
	{
		tx_buf.put(formatReq().getBytes("UTF8"));
	}

	/** Format a config request */
	private String formatReq() {
		StringBuilder sb = new StringBuilder();
		sb.append("config");
		sb.append(UNIT_SEP);
		sb.append(max_pin);
		sb.append(RECORD_SEP);
		return sb.toString();
	}

	/** Get a string representation of the property */
	@Override
	public String toString() {
		return "config: " + max_pin;
	}
}
