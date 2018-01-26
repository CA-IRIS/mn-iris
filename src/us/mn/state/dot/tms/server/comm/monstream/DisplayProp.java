/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2018  Minnesota Department of Transportation
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
import us.mn.state.dot.tms.Camera;
import us.mn.state.dot.tms.PlayList;
import us.mn.state.dot.tms.SystemAttrEnum;
import us.mn.state.dot.tms.server.VideoMonitorImpl;
import us.mn.state.dot.tms.server.comm.Operation;

/**
 * A property for monitor display.
 *
 * @author Douglas Lau
 */
public class DisplayProp extends MonProp {

	/** Get the "blank" camera number */
	static private int cameraNumBlank() {
		return SystemAttrEnum.CAMERA_NUM_BLANK.getInt();
	}

	/** Video monitor */
	private final VideoMonitorImpl monitor;

	/** Create a display property */
	public DisplayProp(VideoMonitorImpl vm) {
		monitor = vm;
	}

	/** Create a display property */
	public DisplayProp() {
		this(null);
	}

	/** Encode a STORE request */
	@Override
	public void encodeStore(Operation op, ByteBuffer tx_buf)
		throws IOException
	{
		tx_buf.put(formatReq().getBytes("UTF8"));
	}

	/** Format a display request */
	private String formatReq() {
		StringBuilder sb = new StringBuilder();
		sb.append("display");
		sb.append(UNIT_SEP);
		sb.append(getMonAsString());
		sb.append(UNIT_SEP);
		sb.append(getCamNumAsString());
		sb.append(UNIT_SEP);
		sb.append(getSeqNumAsString());
		sb.append(RECORD_SEP);
		return sb.toString();
	}

	/** Get monitor number as string */
	private String getMonAsString() {
		return (monitor != null)
		      ? Integer.toString(monitor.getMonNum())
		      : "";
	}

	/** Get camera number as string */
	private String getCamNumAsString() {
		Integer cn = getCamNum();
		return (cn != null) && (cn != cameraNumBlank())
		      ? cn.toString()
		      : "";
	}

	/** Get camera number */
	private Integer getCamNum() {
		Camera c = (monitor != null) ? monitor.getCamera() : null;
		return (c != null) ? c.getCamNum() : null;
	}

	/** Get sequence number as string */
	private String getSeqNumAsString() {
		StringBuilder sb = new StringBuilder();
		PlayList pl = (monitor != null) ? monitor.getPlayList() : null;
		if (pl != null) {
			Integer sn = pl.getNum();
			if (sn != null)
				sb.append(sn);
			assert (monitor != null);
			if (!monitor.isPlayListRunning())
				sb.append(' ').append('"');
		}
		return sb.toString();
	}

	/** Get a string representation of the property */
	@Override
	public String toString() {
		return "display: " + getMonAsString();
	}
}
