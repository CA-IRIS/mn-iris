/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2000-2015  Minnesota Department of Transportation
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
package us.mn.state.dot.tms.client.help;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.EOFException;
import java.net.ConnectException;
import java.text.ParseException;
import javax.naming.AuthenticationException;
import javax.swing.Box;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JPanel;
import us.mn.state.dot.sonar.SonarException;
import us.mn.state.dot.sonar.client.SonarShowException;
import us.mn.state.dot.sonar.client.PermissionException;
import us.mn.state.dot.tms.ChangeVetoException;
import us.mn.state.dot.tms.InvalidMessageException;
import us.mn.state.dot.tms.utils.I18N;
import us.mn.state.dot.tms.client.IrisClient;
import us.mn.state.dot.tms.client.widget.Screen;
import us.mn.state.dot.tms.client.widget.TextPanel;

/**
 * A swing dialog for displaying exception stack traces.
 *
 * @author Douglas Lau
 */
public class ExceptionDialog extends JDialog {

	/** Flag for fatal exceptions */
	private boolean fatal = false;

	/** Set the fatal status */
	private void setFatal(boolean f) {
		fatal = f;
		if (fatal)
			setTitle("Program error");
		else
			setTitle("Warning");
	}

	/** Iris client frame */
	private final IrisClient client;

	/** Create a new exception dialog without an owner */
	public ExceptionDialog() {
		super();
		client = null;
		setResizable(false);
	}

	/** Create a new exception dialog */
	public ExceptionDialog(IrisClient ic) {
		super(ic, true);
		client = ic;
		setResizable(false);
	}

	/** Show an exception */
	public void show(Exception e) {
		e.printStackTrace();
		setFatal(false);
		TextPanel pnl = createMessagePanel(e);
		pnl.add(createButtonBox(e));
		getContentPane().removeAll();
		getContentPane().add(pnl);
		pack();
		Screen.centerOnCurrent(this);
		setVisible(true);
	}

	/** Create a text panel for an exception.
	 * FIXME: add I18n strings. */
	private TextPanel createMessagePanel(final Exception e) {
		TextPanel p = new TextPanel();
		p.addGlue();
		if (e instanceof ConnectException) {
			p.addText("Unable to connect to the IRIS");
			p.addText("server.  Please try again, or");
			p.addText("contact a system administrator");
			p.addText("for assistance.");
			p.addSpacing();
		}
		else if (e instanceof EOFException) {
			if (client != null)
				client.logout();
			p.addText("Lost connection to the IRIS");
			p.addText("server.  Please log in again.");
			p.addSpacing();
		}
		else if (e instanceof AuthenticationException) {
			p.addText("Authentication failed:");
			p.addText(e.getMessage());
			p.addSpacing();
			p.addText("Please make sure your user");
			p.addText("name is correct, then");
			p.addText("type your password again.");
		}
		else if (e instanceof ChangeVetoException) {
			p.addText("The change has been prevented");
			p.addText("for the following reason:");
			p.addSpacing();
			p.addText(e.getMessage());
		}
		else if (e instanceof PermissionException) {
			p.addText("Permission denied:");
			p.addSpacing();
			p.addText(e.getMessage());
		}
		else if (e instanceof SonarShowException) {
			p.addText("The following message was");
			p.addText("received from the IRIS server:");
			p.addSpacing();
			p.addText(e.getMessage());
		}
		else if (e instanceof NumberFormatException) {
			p.addText("Number formatting error");
			p.addSpacing();
			p.addText("Please check all numeric");
			p.addText("fields and try again.");
		}
		else if (e instanceof InvalidMessageException) {
			p.addText("Invalid message");
			p.addSpacing();
			p.addText("The sign is unable to display");
			p.addText("the following message:");
			p.addText(e.getMessage());
			p.addText("Please select a different message");
		}
		else if (e instanceof ParseException) {
			p.addText("Parsing error");
			p.addText(e.getMessage());
			p.addText("Please try again.");
		}
		else if (e instanceof SonarException) {
			setFatal(true);
			p.addText("This program has encountered");
			p.addText("a problem while communicating");
			p.addText("with the IRIS server.");
			p.addSpacing();
			p.addText(e.getMessage());
		}
		else if (e instanceof Exception) {
			setFatal(true);
			p.addText("This program has encountered");
			p.addText("a serious problem.");
			p.addSpacing();
			p.addText("For assistance, contact an");
			p.addText("IRIS system administrator.");
		}
		p.addSpacing();
		String lastLine = I18N.get("help.exception.lastline");
		if (lastLine != null)
			p.addText(lastLine);
		p.addGlue();
		p.addSpacing();
		return p;
	}

	/** Create a button box */
	private Box createButtonBox(final Exception e) {
		Box hbox = Box.createHorizontalBox();
		hbox.add(Box.createHorizontalGlue());
		JButton ok_btn = new JButton("OK");
		ok_btn.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent a) {
				if (fatal)
					System.exit(-1);
				setVisible(false);
				dispose();
			}
		});
		hbox.add(ok_btn);
		if (fatal) {
			hbox.add(Box.createHorizontalStrut(10));
			JButton dtl_btn = new JButton("Detail");
			dtl_btn.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent a) {
					JDialog std = new StackTraceDialog(e);
					std.setVisible(true);
				}
			});
			hbox.add(dtl_btn);
		}
		hbox.add(Box.createHorizontalGlue());
		return hbox;
	}
}
