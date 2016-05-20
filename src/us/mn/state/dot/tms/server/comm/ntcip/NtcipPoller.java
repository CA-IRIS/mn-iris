/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2000-2016  Minnesota Department of Transportation
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
package us.mn.state.dot.tms.server.comm.ntcip;

import java.io.IOException;
import us.mn.state.dot.sched.DebugLog;
import us.mn.state.dot.sonar.User;
import us.mn.state.dot.tms.CommProtocol;
import us.mn.state.dot.tms.DeviceRequest;
import us.mn.state.dot.tms.EventType;
import us.mn.state.dot.tms.InvalidMessageException;
import us.mn.state.dot.tms.SignMessage;
import us.mn.state.dot.tms.server.DMSImpl;
import us.mn.state.dot.tms.server.LCSArrayImpl;
import us.mn.state.dot.tms.server.comm.DevicePoller;
import us.mn.state.dot.tms.server.comm.DMSPoller;
import us.mn.state.dot.tms.server.comm.LCSPoller;
import us.mn.state.dot.tms.server.comm.Messenger;

/**
 * NTCIP Poller
 *
 * @author Douglas Lau
 */
public class NtcipPoller extends DevicePoller implements DMSPoller, LCSPoller {

	/** Get the default URI for a comm protocol */
	static private String default_uri(CommProtocol cp) {
		if (cp == CommProtocol.NTCIP_A)
			return UDP;
		else
			return TCP;
	}

	/** NTCIP debug log */
	static private final DebugLog NTCIP_LOG = new DebugLog("ntcip2");

	/** Communication protocol */
	private final CommProtocol protocol;

	/** Create a new Ntcip poller */
	public NtcipPoller(String n, CommProtocol cp) {
		super(n, default_uri(cp), NTCIP_LOG);
		protocol = cp;
	}

	/** Create a comm thread */
	@Override
	protected NtcipThread createCommThread(String uri, int timeout)
		throws IOException
	{
		return new NtcipThread(this, queue, createMessenger(uri,
			timeout));
	}

	/** Create a messenger */
	private Messenger createMessenger(String uri, int timeout)
		throws IOException
	{
		Messenger m = Messenger.create(d_uri, uri, timeout);
		if (protocol == CommProtocol.NTCIP_B)
			return new HDLCMessenger(m);
		else
			return m;
	}

	/** Send a device request message to the sign */
	@SuppressWarnings("unchecked")
	@Override
	public void sendRequest(DMSImpl dms, DeviceRequest r) {
		switch (r) {
		case RESET_DEVICE:
			addOp(new OpResetDMS(dms));
			break;
		case SEND_SETTINGS:
			addOp(new OpSendDMSFonts(dms));
			addOp(new OpSendDMSDefaults(dms));
			break;
		case QUERY_CONFIGURATION:
			addOp(new OpQueryDMSConfiguration(dms));
			break;
		case QUERY_MESSAGE:
			addOp(new OpQueryDMSMessage(dms));
			break;
		case QUERY_STATUS:
			addOp(new OpQueryDMSStatus(dms));
			break;
		case QUERY_PIXEL_FAILURES:
			addOp(new OpTestDMSPixels(dms, false));
			break;
		case TEST_PIXELS:
			addOp(new OpTestDMSPixels(dms, true));
			break;
		case BRIGHTNESS_TOO_DIM:
			addOp(new OpUpdateDMSBrightness(dms,
				EventType.DMS_BRIGHT_LOW));
			break;
		case BRIGHTNESS_GOOD:
			addOp(new OpUpdateDMSBrightness(dms,
				EventType.DMS_BRIGHT_GOOD));
			break;
		case BRIGHTNESS_TOO_BRIGHT:
			addOp(new OpUpdateDMSBrightness(dms,
				EventType.DMS_BRIGHT_HIGH));
			break;
		case SEND_LEDSTAR_SETTINGS:
			addOp(new OpSendDMSLedstar(dms));
			break;
		default:
			// Ignore other requests
			break;
		}
	}

	/** Send a new message to the sign */
	@SuppressWarnings("unchecked")
	@Override
	public void sendMessage(DMSImpl dms, SignMessage sm, User o)
		throws InvalidMessageException
	{
		if (dms.isMessageCurrentEquivalent(sm))
			addOp(new OpUpdateDMSDuration(dms, sm));
		else
			addOp(new OpSendDMSMessage(dms, sm, o));
	}

	/** Send a device request message to an LCS array */
	@SuppressWarnings("unchecked")
	@Override
	public void sendRequest(LCSArrayImpl lcs_array, DeviceRequest r) {
		switch (r) {
		case SEND_SETTINGS:
			addOp(new OpSendLCSSettings(lcs_array));
			break;
		case QUERY_MESSAGE:
			addOp(new OpQueryLCSIndications(lcs_array));
			break;
		default:
			// Ignore other requests
			break;
		}
	}

	/** Send new indications to an LCS array.
	 * @param lcs_array LCS array.
	 * @param ind New lane use indications.
	 * @param o User who deployed the indications. */
	@SuppressWarnings("unchecked")
	@Override
	public void sendIndications(LCSArrayImpl lcs_array, Integer[] ind,
		User o)
	{
		addOp(new OpSendLCSIndications(lcs_array, ind, o));
	}
}
