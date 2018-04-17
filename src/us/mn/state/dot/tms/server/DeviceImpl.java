/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2000-2018  Minnesota Department of Transportation
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

import us.mn.state.dot.sched.DebugLog;
import us.mn.state.dot.sonar.SonarException;
import us.mn.state.dot.tms.ChangeVetoException;
import us.mn.state.dot.tms.Controller;
import us.mn.state.dot.tms.ControllerHelper;
import us.mn.state.dot.tms.ControllerIO;
import us.mn.state.dot.tms.Device;
import us.mn.state.dot.tms.DeviceRequest;
import us.mn.state.dot.tms.ItemStyle;
import us.mn.state.dot.tms.TMSException;
import us.mn.state.dot.tms.server.comm.DevicePoller;
import us.mn.state.dot.tms.server.comm.OpDevice;

/**
 * DeviceImpl is the base class for all field devices, including detectors,
 * cameras, ramp meters, dynamic message signs, etc.
 *
 * @author Douglas Lau
 */
abstract public class DeviceImpl extends BaseObjectImpl implements Device,
	ControllerIO
{
	/** Device debug log */
	static private final DebugLog DEVICE_LOG = new DebugLog("device");

	/** Log a device message */
	protected void logError(String msg) {
		if (DEVICE_LOG.isOpen())
			DEVICE_LOG.log(getName() + ": " + msg);
	}

	/** Create a new device */
	protected DeviceImpl(String n) throws TMSException, SonarException {
		super(n);
		notes = "";
	}

	/** Create a device */
	protected DeviceImpl(String n, ControllerImpl c, int p, String nt) {
		super(n);
		controller = c;
		pin = p;
		notes = nt;
	}

	/** Initialize the controller for this device */
	@Override
	public void initTransients() {
		ControllerImpl c = controller;
		if (c != null)
			c.setIO(pin, this);
		updateStyles();
	}

	/** Get the device poller */
	public DevicePoller getPoller() {
		ControllerImpl c = controller;	// Avoid race
		return (c != null) ? c.getPoller() : null;
	}

	/** Controller associated with this traffic device */
	protected ControllerImpl controller;

	/** Update the controller and/or pin.
	 * @param oc Old controller.
	 * @param op Old pin.
	 * @param nc New controller.
	 * @param np New pin. */
	protected void updateControllerPin(ControllerImpl oc, int op,
		ControllerImpl nc, int np)
	{
		if (oc != null)
			oc.setIO(op, null);
		if (nc != null)
			nc.setIO(np, this);
		updateStyles();
	}

	/** Set the controller of the device */
	@Override
	public void setController(Controller c) {
		controller = (ControllerImpl) c;
	}

	/** Set the controller of the device */
	public void doSetController(Controller c) throws TMSException {
		if (c == controller)
			return;
		if (c == null || c instanceof ControllerImpl)
			doSetControllerImpl((ControllerImpl) c);
		else
			throw new ChangeVetoException("Invalid controller");
	}

	/** Set the controller of the device */
	protected void doSetControllerImpl(ControllerImpl c)
		throws TMSException
	{
		if (c != null && controller != null)
			throw new ChangeVetoException("Device has controller");
		if (pin < 1 || pin > Controller.ALL_PINS)
			throw new ChangeVetoException("Invalid pin: " + pin);
		if (c != null)
			checkControllerPin(pin);
		store.update(this, "controller", c);
		updateControllerPin(controller, pin, c, pin);
		setController(c);
	}

	/** Check the controller pin */
	protected void checkControllerPin(int p) throws TMSException {
		ControllerImpl c = controller;
		if (c != null && c.getIO(p) != null)
			throw new ChangeVetoException("Unavailable pin: " + p);
	}

	/** Get the controller to which this device is assigned */
	@Override
	public Controller getController() {
		return controller;
	}

	/** Controller I/O pin number */
	protected int pin = 0;

	/** Set the controller I/O pin number */
	@Override
	public void setPin(int p) {
		pin = p;
	}

	/** Set the controller I/O pin number */
	public void doSetPin(int p) throws TMSException {
		if (p == pin)
			return;
		if (p < 1 || p > Controller.ALL_PINS)
			throw new ChangeVetoException("Invalid pin: " + p);
		store.update(this, "pin", p);
		updateControllerPin(controller, pin, controller, p);
		setPin(p);
	}

	/** Get the controller I/O pin number */
	@Override
	public int getPin() {
		return pin;
	}

	/** Administrator notes for this device */
	protected String notes;

	/** Set the administrator notes */
	@Override
	public void setNotes(String n) {
		notes = n;
	}

	/** Set the administrator notes */
	public void doSetNotes(String n) throws TMSException {
		if (!objectEquals(n, notes)) {
			store.update(this, "notes", n);
			setNotes(n);
		}
	}

	/** Get the administrator notes */
	@Override
	public String getNotes() {
		return notes;
	}

	/** Operation which owns the device */
	private transient OpDevice owner;

	/** Acquire ownership of the device */
	public OpDevice acquire(OpDevice o) {
		try {
			// Name used for unique device acquire/release lock
			synchronized (name) {
				if (owner == null)
					owner = o;
				return owner;
			}
		}
		finally {
			if (owner == o)
				notifyAttribute("operation");
		}
	}

	/** Release ownership of the device */
	public OpDevice release(OpDevice o) {
		try {
			// Name used for unique device acquire/release lock
			synchronized(name) {
				OpDevice _owner = owner;
				if (owner == o)
					owner = null;
				return _owner;
			}
		}
		finally {
			if (owner == null)
				notifyAttribute("operation");
		}
	}

	/** Get a description of the current device operation */
	@Override
	public String getOperation() {
		OpDevice o = owner;
		return (o != null) ? o.getOperationDescription() : "None";
	}

	/** Item style bits */
	private transient long styles = calculateStyles();

	/** Get item style bits */
	@Override
	public long getStyles() {
		return styles;
	}

	/** Set the item style bits (and notify clients) */
	private final void setStyles(long s) {
		if (s != styles) {
			styles = s;
			notifyAttribute("styles");
		}
	}

	/** Update the device item styles */
	public void updateStyles() {
		setStyles(calculateStyles());
	}

	/** Calculate the item styles */
	protected long calculateStyles() {
		long s = ItemStyle.ALL.bit();
		if (isActive())
			s |= ItemStyle.ACTIVE.bit();
		else
			s |= ItemStyle.INACTIVE.bit();
		if (isAvailable())
			s |= ItemStyle.AVAILABLE.bit();
		if (isOnline() && needsMaintenance())
			s |= ItemStyle.MAINTENANCE.bit();
		if (isActive() && isFailed())
			s |= ItemStyle.FAILED.bit();
		if (getController() == null)
			s |= ItemStyle.NO_CONTROLLER.bit();
		return s;
	}

	/** Get the active status */
	public boolean isActive() {
		ControllerImpl c = controller;	// Avoid race
		return (c != null) && c.isActive();
	}

	/** Get the failure status */
	public boolean isFailed() {
		ControllerImpl c = controller;	// Avoid race
		// FIXME: check if comm link connected
		//        needs status update to work properly
		return (c == null) || c.isFailed();
	}

	/** Test if device is online (active and not failed) */
	public boolean isOnline() {
		return isActive() && !isFailed();
	}

	/** Test if device is available */
	protected boolean isAvailable() {
		return isOnline() && !needsMaintenance();
	}

	/** Test if a device needs maintenance */
	protected boolean needsMaintenance() {
		return !getMaintenance().isEmpty();
	}

	/** Get maintenance status */
	private String getMaintenance() {
		return ControllerHelper.getMaintenance(getController());
	}

	/** Check if the controller has an error */
	public boolean hasError() {
		return isFailed() || hasStatusError();
	}

	/** Check if the controller has a status error */
	private boolean hasStatusError() {
		ControllerImpl c = controller;	// Avoid race
		return (c == null) || !c.getStatus().isEmpty();
	}

	/** Destroy an object */
	@Override
	public void doDestroy() throws TMSException {
		// Don't allow a device to be destroyed if it is assigned to
		// a controller.  This is needed because the Controller io_pins
		// HashMap will still have a reference to the device.
		if (controller != null) {
			throw new ChangeVetoException("Device must be removed" +
				" from controller before being destroyed: " +
				name);
		}
		super.doDestroy();
	}

	/** Get the polling period (sec) */
	protected int getPollPeriod() {
		ControllerImpl c = controller;	// Avoid race
		return (c != null) ? c.getPollPeriod() : 30;
	}

	/** Check if link is any type of modem (dial-up or cell) */
	public boolean isModemAny() {
		ControllerImpl c = controller;
		return (c != null) && c.isModemAny();
	}

	/** Check if the device is on a "connected" comm link */
	protected boolean isConnected() {
		ControllerImpl c = controller;
		return (c != null) && c.isConnected();
	}

	/** Check if dial-up is required to communicate */
	public boolean isDialUpRequired() {
		ControllerImpl c = controller;
		return (c != null) && c.isDialUpRequired();
	}

	/** Request a device operation */
	@Override
	public void setDeviceRequest(int r) {
		sendDeviceRequest(DeviceRequest.fromOrdinal(r));
	}

	/** Request a device operation */
	public final void setDeviceReq(DeviceRequest dr) {
		sendDeviceRequest(dr);
	}

	/** Send a device request operation */
	abstract protected void sendDeviceRequest(DeviceRequest dr);

	/** Perform a periodic poll */
	public void periodicPoll() {
		sendDeviceRequest(DeviceRequest.QUERY_STATUS);
	}
}
