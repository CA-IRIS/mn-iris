/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2000-2009  Minnesota Department of Transportation
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
package us.mn.state.dot.tms.comm.aws;

import java.util.Calendar;
import us.mn.state.dot.sched.Completer;
import us.mn.state.dot.sched.Job;
import us.mn.state.dot.sched.Scheduler;
import us.mn.state.dot.sonar.server.ServerNamespace;
import us.mn.state.dot.tms.ControllerImpl;
import us.mn.state.dot.tms.SystemAttrEnum;
import us.mn.state.dot.tms.comm.AddressedMessage;
import us.mn.state.dot.tms.comm.DiagnosticOperation;
import us.mn.state.dot.tms.comm.HttpFileMessenger;
import us.mn.state.dot.tms.comm.MessagePoller;
import us.mn.state.dot.tms.comm.Messenger;
//import us.mn.state.dot.tms.comm.SignPoller; FIXME
import us.mn.state.dot.tms.utils.I18N;
import us.mn.state.dot.tms.utils.Log;
import us.mn.state.dot.tms.utils.STime;

/**
 * AWS poller, which periodically retrieves DMS messages
 * generated by the external AWS system via the specified URL.
 *
 * @author Douglas Lau
 * @author Michael Darter
 */
public class AwsPoller extends MessagePoller // FIXME implements SignPoller
{
	/** 30 sec AWS job will execute at :08 and :38 */
	private static final int JOB_EXEC_TIME_SECS = 8;

	/** Create scheduler that runs AWS activation job */
	static protected final Scheduler m_scheduler =
		new Scheduler("Scheduler: AWS Activation");

	/** the only valid drop address */
	static public final int VALID_DROP_ADDRESS = 1;

	/** server namespace */
	final ServerNamespace m_namespace;

	/** associated controller */
	private ControllerImpl m_awsController = null;

	/** Create a new poller */
	public AwsPoller(String n, Messenger m, ServerNamespace namespace) {
		super(n, m);
		assert m instanceof HttpFileMessenger;
		m_namespace = namespace;

		// add 30 second timer to aws scheduler
		m_scheduler.addJob(new AwsTimerJob());
	}

	/** Create a new message for the specified controller, 
	 *  called by MessagePoller.doPoll(). */
	public AddressedMessage createMessage(ControllerImpl c) {
		// Log.finest("AwsPoller.createMessage() called.");
		return new Message(messenger);
	}

	/** Check if a drop address is valid */
	public boolean isAddressValid(int drop) {
		return (drop == VALID_DROP_ADDRESS);
	}

	/** Perform a controller download, which happens every 
	 *  morning at 4am. */
	public void download(ControllerImpl c, boolean reset, int p) {}

	/** Perform a sign status poll. Defined in SignPoller interface. */
	// FIXME public void pollSigns(ControllerImpl c, Completer comp) {}

	/** Perform a 30-second poll */
	public void poll30Second(ControllerImpl c, Completer comp) {
		// FIXME: should get the controller from sonar
		if(c != m_awsController)
			m_awsController = c;
	}

	/** Perform a 5-minute poll */
	public void poll5Minute(ControllerImpl c, Completer comp) {}

	/**
	 * Start a test for the given controller.  This method is activated
	 * when the user clicks the checkbox 'test communication' on the
	 * the controller dialog in the status tab.
	 * @see us.mn.state.dot.tms.ControllerImpl#testCommunications
	 */
	public DiagnosticOperation startTest(ControllerImpl c) {
		// Log.finest("AwsPoller.startTest() called.");
		return null;
	}

	/** return name of AWS system */
	public static String awsName() {
		return I18N.get("Aws.Name");
	}

	/** get the one AWS controller */
	protected ControllerImpl getController() {
		//if(m_namespace == null)
		//	return null;
		return m_awsController;
	}

	/** AWS timer job */
	protected class AwsTimerJob extends Job {

		/** Job completer */
		protected final Completer m_comp;

		/** Current time stamp */
		protected Calendar stamp;

		/** Job to be performed on completion */
		protected final Job job = new Job() {
			public void perform() {
				// nothing
			}
		};

		/** Create a new 30-second timer job */
		protected AwsTimerJob() {
			super(Calendar.SECOND, 30, Calendar.SECOND, 
				JOB_EXEC_TIME_SECS);
			m_comp = new Completer("30-Second", m_scheduler, job);
		}

		/** Perform the 30-second timer job */
		public void perform() throws Exception {
			if(!m_comp.checkComplete())
				return;
			Calendar s = Calendar.getInstance();
			s.add(Calendar.SECOND, -30);
			stamp = s;
			m_comp.reset(stamp);
			try {
				doWork();
			} finally {
				m_comp.makeReady();
			}
		}

		/** do the job work */
		private void doWork() {
			if(getController() == null) 
				return;
			if(SystemAttrEnum.DMS_AWS_ENABLE.getBoolean())
				new OpProcessAwsMsgs(getController()).start();
		}
	}
}
