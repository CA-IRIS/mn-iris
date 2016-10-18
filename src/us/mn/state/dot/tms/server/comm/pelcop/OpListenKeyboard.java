/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2016  Minnesota Department of Transportation
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
package us.mn.state.dot.tms.server.comm.pelcop;

import java.io.IOException;
import java.nio.BufferUnderflowException;
import java.nio.ByteBuffer;
import java.nio.InvalidMarkException;
import us.mn.state.dot.tms.server.comm.Operation;
import us.mn.state.dot.tms.server.comm.OpStep;

/**
 * Operation step to listen for keyboard commands.
 *
 * @author Douglas Lau
 */
public class OpListenKeyboard extends OpStep {

	/** Most recent property request */
	private PelcoPProp prop;

	/** Create a new listen keyboard step */
	public OpListenKeyboard() {
		setPolling(false);
	}

	/** Poll the controller */
	@Override
	public void poll(Operation op, ByteBuffer tx_buf) throws IOException {
		if (prop != null) {
			try {
				doPoll(op, tx_buf);
			}
			catch (InvalidMarkException e) {
				// dumb exception
			}
			prop = null;
		}
		setPolling(false);
	}

	/** Poll the controller with one packeet */
	private void doPoll(Operation op, ByteBuffer tx_buf) throws IOException{
		PelcoPProp.formatHead(tx_buf);
		prop.encodeQuery(op, tx_buf);
		PelcoPProp.formatTail(tx_buf);
	}

	/** Parse data received from controller */
	@Override
	public void recv(Operation op, ByteBuffer rx_buf) throws IOException {
		try {
			doRecv(op, rx_buf);
		}
		catch (InvalidMarkException e) {
			// what a stupid exception
		}
	}

	/** Parse received data */
	private void doRecv(Operation op, ByteBuffer rx_buf) throws IOException{
		try {
			prop = PelcoPProp.parse(rx_buf);
			prop.decodeQuery(op, rx_buf);
			prop.parseTail(rx_buf);
			setPolling(true);
		}
		catch (BufferUnderflowException e) {
			rx_buf.reset();
		}
	}

	/** Get the next step */
	@Override
	public OpStep next() {
		return this;
	}
}
