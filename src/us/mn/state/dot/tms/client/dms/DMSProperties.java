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
package us.mn.state.dot.tms.client.dms;

import java.awt.BorderLayout;
import java.awt.CardLayout;
import java.awt.Color;
import java.io.IOException;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JSpinner;
import javax.swing.JTabbedPane;
import javax.swing.JTextArea;
import javax.swing.ListSelectionModel;
import javax.swing.SpinnerNumberModel;
import us.mn.state.dot.sched.ActionJob;
import us.mn.state.dot.sched.ChangeJob;
import us.mn.state.dot.sched.FocusJob;
import us.mn.state.dot.sonar.User;
import us.mn.state.dot.sonar.client.TypeCache;
import us.mn.state.dot.tms.Base64;
import us.mn.state.dot.tms.BitmapGraphic;
import us.mn.state.dot.tms.Camera;
import us.mn.state.dot.tms.Controller;
import us.mn.state.dot.tms.DeviceRequest;
import us.mn.state.dot.tms.DMS;
import us.mn.state.dot.tms.DMSType;
import us.mn.state.dot.tms.SystemAttrEnum;
import us.mn.state.dot.tms.client.dms.quicklib.QuickMessageEditorTab;
import us.mn.state.dot.tms.client.Session;
import us.mn.state.dot.tms.client.SonarState;
import us.mn.state.dot.tms.client.schedule.TimingPlanModel;
import us.mn.state.dot.tms.client.toast.ControllerForm;
import us.mn.state.dot.tms.client.toast.FormPanel;
import us.mn.state.dot.tms.client.toast.LocationPanel;
import us.mn.state.dot.tms.client.toast.SonarObjectForm;
import us.mn.state.dot.tms.client.toast.WrapperComboBoxModel;
import us.mn.state.dot.tms.client.widget.ZTable;
import us.mn.state.dot.tms.client.widget.IButton;
import us.mn.state.dot.tms.utils.I18N;

/**
 * This is a form for viewing and editing the properties of a dynamic message
 * sign (DMS).
 *
 * @author Douglas Lau
 * @author Michael Darter
 */
public class DMSProperties extends SonarObjectForm<DMS> {

	/** Format a string field */
	static protected String formatString(String s) {
		if(s != null && s.length() > 0)
			return s;
		else
			return UNKNOWN;
	}

	/** Format milimeter units for display */
	static protected String formatMM(Integer i) {
		if(i != null && i > 0)
			return i + " mm";
		else
			return UNKNOWN;
	}

	/** Format pixel units for display */
	static protected String formatPixels(Integer i) {
		if(i != null) {
			if(i > 0)
				return i + " pixels";
			else if(i == 0)
				return "Variable";
		}
		return UNKNOWN;
	}

	/** Format the temperature */
	static protected String formatTemp(Integer minTemp, Integer maxTemp) {
		if(minTemp == null || minTemp == maxTemp)
			return Temperature.formatCelsius(maxTemp);
		if(maxTemp == null)
			return Temperature.formatCelsius(minTemp);
		return Temperature.formatCelsius(minTemp) + " ... " +
		       Temperature.formatCelsius(maxTemp);
	}

	/** Frame title */
	static protected String TITLE = I18N.get("dms.abbreviation") + ": ";

	/** Generic sign make */
	static protected final String MAKE_GENERIC = "Generic";

	/** Ledstar sign make */
	static protected final String MAKE_LEDSTAR = "Ledstar";

	/** Skyline sign make */
	static protected final String MAKE_SKYLINE = "Skyline";

	/** Location panel */
	protected LocationPanel location;

	/** Notes text area */
	protected final JTextArea notes = new JTextArea(3, 24);

	/** Camera combo box */
	protected final JComboBox camera = new JComboBox();

	/** Controller button */
	protected final JButton controllerBtn = new JButton("Controller");

	/** Messages tab */
	protected final MessagesTab messagesTab;

	/** Quick Library tab */
	protected final QuickMessageEditorTab qlibTab;

	/** Sign type label */
	protected final JLabel type = new JLabel();

	/** Sign technology label */
	protected final JLabel tech = new JLabel();

	/** Sign access label */
	protected final JLabel access = new JLabel();

	/** Sign legend label */
	protected final JLabel legend = new JLabel();

	/** Beacon label */
	protected final JLabel beacon = new JLabel();

	/** Sign face width label */
	protected final JLabel faceWidth = new JLabel();

	/** Sign face height label */
	protected final JLabel faceHeight = new JLabel();

	/** Horizontal border label */
	protected final JLabel hBorder = new JLabel();

	/** Vertical border label */
	protected final JLabel vBorder = new JLabel();

	/** Horizontal pitch label */
	protected final JLabel hPitch = new JLabel();

	/** Vertical pitch label */
	protected final JLabel vPitch = new JLabel();

	/** Sign width (pixels) label */
	protected final JLabel pWidth = new JLabel();

	/** Sign height (pixels) label */
	protected final JLabel pHeight = new JLabel();

	/** Character width label */
	protected final JLabel cWidth = new JLabel();

	/** Character height label */
	protected final JLabel cHeight = new JLabel();

	/** Cabinet temperature label */
	protected final JLabel cabinetTemp = new JLabel();

	/** Ambient temperature label */
	protected final JLabel ambientTemp = new JLabel();

	/** Housing temperature label */
	protected final JLabel housingTemp = new JLabel();

	/** Operation description label */
	protected final JLabel operation = new JLabel();

	/** Bad pixel count label */
	protected final JLabel badPixels = new JLabel();

	/** Stuck off pixel panel */
	protected final SignPixelPanel stuck_off_pnl = new SignPixelPanel(true);

	/** Stuck on pixel panel */
	protected final SignPixelPanel stuck_on_pnl = new SignPixelPanel(true);

	/** Lamp status table */
	protected final ZTable lampTable = new ZTable();

	/** Light output label */
	protected final JLabel lightOutput = new JLabel();

	/** Brightness feedback combo box */
	protected final JComboBox feedback = new JComboBox(
		new DeviceRequest[] {
			DeviceRequest.NO_REQUEST,
			DeviceRequest.BRIGHTNESS_GOOD,
			DeviceRequest.BRIGHTNESS_TOO_DIM,
			DeviceRequest.BRIGHTNESS_TOO_BRIGHT
		}
	);

	/** Card layout for manufacturer panels */
	protected final CardLayout cards = new CardLayout();

	/** Card panel for manufacturer panels */
	protected final JPanel card_panel = new JPanel(cards);

	/** Make label */
	protected final JLabel make = new JLabel();

	/** Model label */
	protected final JLabel model = new JLabel();

	/** Version label */
	protected final JLabel version = new JLabel();

	/** Spinner to adjuct LDC pot base */
	protected final JSpinner ldcPotBaseSpn = new JSpinner(
		new SpinnerNumberModel(20, 20, 65, 5));

	/** Pixel current low threshold spinner */
	protected final JSpinner currentLowSpn = new JSpinner(
		new SpinnerNumberModel(5, 0, 100, 1));

	/** Pixel current high threshold spinner */
	protected final JSpinner currentHighSpn = new JSpinner(
		new SpinnerNumberModel(40, 0, 100, 1));

	/** Power supply status table */
	protected final ZTable powerTable = new ZTable();

	/** Heat tape status label */
	protected final JLabel heatTapeStatus = new JLabel();

	/** Sonar state */
	protected final SonarState state;

	/** SONAR user */
	protected final User user;

	/** Create a new DMS properties form */
	public DMSProperties(Session s, DMS sign) {
		super(TITLE, s, sign);
		setHelpPageName("Help.DMSProperties");
		state = s.getSonarState();
		user = s.getUser();
		messagesTab = new MessagesTab(s, sign);
		qlibTab = new QuickMessageEditorTab(
			state.getDmsCache().getQuickMessages(), this,
			state.getNamespace(), user);
	}

	/** Get the SONAR type cache */
	protected TypeCache<DMS> getTypeCache() {
		return state.getDmsCache().getDMSs();
	}

	/** Initialize the widgets on the form */
	protected void initialize() {
		super.initialize();
		JTabbedPane tab = new JTabbedPane();
		tab.add("Location", createLocationPanel());
		tab.add("Messages", messagesTab);
		tab.add("Configuration", createConfigurationPanel());
		tab.add("Status", createStatusPanel());
		if(SystemAttrEnum.DMS_PIXEL_STATUS_ENABLE.getBoolean())
			tab.add("Pixels", createPixelPanel());
		if(SystemAttrEnum.DMS_BRIGHTNESS_ENABLE.getBoolean())
			tab.add("Brightness", createBrightnessPanel());
		if(SystemAttrEnum.DMS_MANUFACTURER_ENABLE.getBoolean())
			tab.add("Manufacturer", createManufacturerPanel());
		tab.add(qlibTab.getTabText(), qlibTab);
		add(tab);
		updateAttribute(null);
		setBackground(Color.LIGHT_GRAY);
	}

	/** Dispose of the form */
	protected void dispose() {
		location.dispose();
		messagesTab.dispose();
		qlibTab.dispose();
		super.dispose();
	}

	/** Create the location panel */
	protected JPanel createLocationPanel() {
		new FocusJob(notes) {
			public void perform() {
				proxy.setNotes(notes.getText());
			}
		};
		new ActionJob(this, camera) {
			public void perform() {
				proxy.setCamera(
					(Camera)camera.getSelectedItem());
			}
		};
		new ActionJob(this, controllerBtn) {
			public void perform() {
				controllerPressed();
			}
		};
		location = new LocationPanel(true, proxy.getGeoLoc(), state);
		location.initialize();
		location.addRow("Notes", notes);
		camera.setModel(new WrapperComboBoxModel(
			state.getCamCache().getCameraModel()));
		location.add("Camera", camera);
		location.finishRow();
		location.setCenter();
		location.addRow(controllerBtn);
		return location;
	}

	/** Controller lookup button pressed */
	protected void controllerPressed() {
		Controller c = proxy.getController();
		if(c == null)
			controllerBtn.setEnabled(false);
		else {
			session.getDesktop().show(
				new ControllerForm(session, c));
		}
	}

	/** Create the configuration panel */
	protected JPanel createConfigurationPanel() {
		type.setForeground(OK);
		tech.setForeground(OK);
		access.setForeground(OK);
		legend.setForeground(OK);
		beacon.setForeground(OK);
		faceWidth.setForeground(OK);
		faceHeight.setForeground(OK);
		hBorder.setForeground(OK);
		vBorder.setForeground(OK);
		hPitch.setForeground(OK);
		vPitch.setForeground(OK);
		pWidth.setForeground(OK);
		pHeight.setForeground(OK);
		cWidth.setForeground(OK);
		cHeight.setForeground(OK);
		FormPanel panel = new FormPanel(true);
		panel.addRow("Type", type);
		panel.addRow("Technology", tech);
		panel.addRow("Access", access);
		panel.addRow("Legend", legend);
		panel.addRow("Beacon", beacon);
		panel.addRow("Face width", faceWidth);
		panel.addRow("Face height", faceHeight);
		panel.addRow("Horizontal border", hBorder);
		panel.addRow("Vertical border", vBorder);
		panel.addRow("Horizontal pitch", hPitch);
		panel.addRow("Vertical pitch", vPitch);
		panel.addRow("Sign width", pWidth);
		panel.addRow("Sign height", pHeight);
		panel.addRow("Character width", cWidth);
		panel.addRow("Character height", cHeight);
		JButton configBtn = new JButton("Query Configuration");
		new ActionJob(this, configBtn) {
			public void perform() {
				proxy.setDeviceRequest(DeviceRequest.
					QUERY_CONFIGURATION.ordinal());
			}
		};
		panel.addRow(configBtn);
		return panel;
	}

	/** Create status panel */
	protected JPanel createStatusPanel() {
		cabinetTemp.setForeground(OK);
		ambientTemp.setForeground(OK);
		housingTemp.setForeground(OK);
		operation.setForeground(OK);
		FormPanel panel = new FormPanel(true);
		panel.addRow("Cabinet temp", cabinetTemp);
		panel.addRow("Ambient temp", ambientTemp);
		panel.addRow("Housing temp", housingTemp);
		panel.add("Operation", operation);
		IButton queryMsgBtn = new IButton("dms.query.msg", 
			SystemAttrEnum.DMS_QUERYMSG_ENABLE);
		if(queryMsgBtn.getIEnabled()) {
			panel.add(queryMsgBtn);
			new ActionJob(this, queryMsgBtn) {
				public void perform() throws Exception {
					proxy.setDeviceRequest(DeviceRequest.
						QUERY_MESSAGE.ordinal());
				}
			};
		}
		panel.finishRow();
		IButton resetBtn = new IButton("dms.reset", 
			SystemAttrEnum.DMS_RESET_ENABLE);
		if(resetBtn.getIEnabled()) {
			panel.addRow(resetBtn);
			new ActionJob(this, resetBtn) {
				public void perform() {
					proxy.setDeviceRequest(DeviceRequest.
						RESET_DEVICE.ordinal());
				}
			};
		}
		JButton settingsBtn = new JButton("Send Settings");
		new ActionJob(this, settingsBtn) {
			public void perform() {
				proxy.setDeviceRequest(DeviceRequest.
					SEND_SETTINGS.ordinal());
			}
		};
		panel.addRow(settingsBtn);
		return panel;
	}

	/** Create pixel panel */
	protected JPanel createPixelPanel() {
		JButton queryBtn = new JButton("Query Pixel Failures");
		new ActionJob(this, queryBtn) {
			public void perform() {
				proxy.setDeviceRequest(DeviceRequest.
					QUERY_PIXEL_FAILURES.ordinal());
			}
		};
		JButton testBtn = new JButton("Test Pixels");
		new ActionJob(this, testBtn) {
			public void perform() {
				proxy.setDeviceRequest(
					DeviceRequest.TEST_PIXELS.ordinal());
			}
		};
		JPanel buttonPnl = new JPanel();
		buttonPnl.add(queryBtn);
		buttonPnl.add(testBtn);
		badPixels.setForeground(OK);
		FormPanel panel = new FormPanel(true);
		panel.addRow("Pixel errors", badPixels);
		panel.setFill();
		panel.addRow(createTitledPanel("Stuck Off", stuck_off_pnl));
		panel.setFill();
		panel.addRow(createTitledPanel("Stuck On", stuck_on_pnl));
		panel.setCenter();
		panel.add(buttonPnl);
		return panel;
	}

	/** Create a panel with a titled border */
	protected JPanel createTitledPanel(String title, JPanel p) {
		JPanel panel = new JPanel(new BorderLayout());
		panel.setBorder(BorderFactory.createTitledBorder(title));
		panel.add(p, BorderLayout.CENTER);
		return panel;
	}

	/** Create brightness panel */
	protected JPanel createBrightnessPanel() {
		new ActionJob(this, feedback) {
			public void perform() {
				DeviceRequest sr = (DeviceRequest)
					feedback.getSelectedItem();
				proxy.setDeviceRequest(sr.ordinal());
				feedback.setEnabled(false);
			}
		};
		JButton testBtn = new JButton("Test Lamps");
		new ActionJob(this, testBtn) {
			public void perform() {
				proxy.setDeviceRequest(
					DeviceRequest.TEST_LAMPS.ordinal());
			}
		};
		lightOutput.setForeground(OK);
		FormPanel panel = new FormPanel(true);
		panel.addRow("Lamp status", lampTable);
		panel.addRow("Light output", lightOutput);
		panel.addRow("Feedback", feedback);
		panel.setCenter();
		panel.addRow(testBtn);
		return panel;
	}

	/** Create manufacturer-specific panel */
	protected JPanel createManufacturerPanel() {
		make.setForeground(OK);
		model.setForeground(OK);
		version.setForeground(OK);
		FormPanel panel = new FormPanel(true);
		panel.addRow("Make", make);
		panel.addRow("Model", model);
		panel.addRow("Version", version);
		panel.addRow(card_panel);
		card_panel.add(createGenericPanel(), MAKE_GENERIC);
		card_panel.add(createLedstarPanel(), MAKE_LEDSTAR);
		card_panel.add(createSkylinePanel(), MAKE_SKYLINE);
		return panel;
	}

	/** Create generic manufacturer panel */
	protected JPanel createGenericPanel() {
		FormPanel panel = new FormPanel(true);
		panel.setTitle("Unknown manufacturer");
		panel.addRow(new JLabel("Nothing to see here"));
		return panel;
	}

	/** Create Ledstar-specific panel */
	protected JPanel createLedstarPanel() {
		new ChangeJob(this, ldcPotBaseSpn) {
			public void perform() {
				Number n = (Number)ldcPotBaseSpn.getValue();
				proxy.setLdcPotBase(n.intValue());
			}
		};
		new ChangeJob(this, currentLowSpn) {
			public void perform() {
				Number n = (Number)currentLowSpn.getValue();
				proxy.setPixelCurrentLow(n.intValue());
			}
		};
		new ChangeJob(this, currentHighSpn) {
			public void perform() {
				Number n = (Number)currentHighSpn.getValue();
				proxy.setPixelCurrentHigh(n.intValue());
			}
		};
		FormPanel panel = new FormPanel(true);
		panel.setTitle(MAKE_LEDSTAR);
		panel.addRow("LDC pot base", ldcPotBaseSpn);
		panel.addRow("Pixel current low threshold", currentLowSpn);
		panel.addRow("Pixel current high threshold", currentHighSpn);
		return panel;
	}

	/** Create Skyline-specific panel */
	protected JPanel createSkylinePanel() {
		powerTable.setAutoCreateColumnsFromModel(false);
		powerTable.setVisibleRowCount(8);
		heatTapeStatus.setForeground(OK);
		FormPanel panel = new FormPanel(true);
		panel.setTitle(MAKE_SKYLINE);
		panel.addRow(powerTable);
		panel.addRow("Heat tape", heatTapeStatus);
		return panel;
	}

	/** Update one attribute on the form */
	protected void updateAttribute(String a) {
		messagesTab.updateAttribute(a);
		if(a == null || a.equals("notes"))
			notes.setText(proxy.getNotes());
		if(a == null || a.equals("camera"))
			camera.setSelectedItem(proxy.getCamera());
		if(a == null || a.equals("make")) {
			String m = formatString(proxy.getMake());
			make.setText(m);
			updateMake(m.toUpperCase());
		}
		if(a == null || a.equals("model"))
			model.setText(formatString(proxy.getModel()));
		if(a == null || a.equals("version"))
			version.setText(formatString(proxy.getVersion()));
		if(a == null || a.equals("signAccess"))
			access.setText(formatString(proxy.getSignAccess()));
		if(a == null || a.equals("dmsType")) {
			DMSType t = DMSType.fromOrdinal(proxy.getDmsType());
			type.setText(t.description);
		}
		if(a == null || a.equals("faceHeight"))
			faceHeight.setText(formatMM(proxy.getFaceHeight()));
		if(a == null || a.equals("faceWidth"))
			faceWidth.setText(formatMM(proxy.getFaceWidth()));
		if(a == null || a.equals("heightPixels"))
			pHeight.setText(formatPixels(proxy.getHeightPixels()));
		if(a == null || a.equals("widthPixels"))
			pWidth.setText(formatPixels(proxy.getWidthPixels()));
		if(a == null || a.equals("horizontalBorder"))
			hBorder.setText(formatMM(proxy.getHorizontalBorder()));
		if(a == null || a.equals("verticalBorder"))
			vBorder.setText(formatMM(proxy.getVerticalBorder()));
		if(a == null || a.equals("legend"))
			legend.setText(formatString(proxy.getLegend()));
		if(a == null || a.equals("beaconType"))
			beacon.setText(formatString(proxy.getBeaconType()));
		if(a == null || a.equals("technology"))
			tech.setText(formatString(proxy.getTechnology()));
		if(a == null || a.equals("charHeightPixels")) {
			cHeight.setText(formatPixels(
				proxy.getCharHeightPixels()));
		}
		if(a == null || a.equals("charWidthPixels")) {
			cWidth.setText(formatPixels(
				proxy.getCharWidthPixels()));
		}
		if(a == null || a.equals("horizontalPitch"))
			hPitch.setText(formatMM(proxy.getHorizontalPitch()));
		if(a == null || a.equals("verticalPitch"))
			vPitch.setText(formatMM(proxy.getVerticalPitch()));
		// NOTE: messageCurrent attribute changes after all sign
		//       dimension attributes are updated.
		if(a == null || a.equals("messageCurrent"))
			updatePixelStatus();
		if(a == null || a.equals("ldcPotBase")) {
			Integer b = proxy.getLdcPotBase();
			if(b != null)
				ldcPotBaseSpn.setValue(b);
		}
		if(a == null || a.equals("pixelCurrentLow")) {
			Integer c = proxy.getPixelCurrentLow();
			if(c != null)
				currentLowSpn.setValue(c);
		}
		if(a == null || a.equals("pixelCurrentHigh")) {
			Integer c = proxy.getPixelCurrentHigh();
			if(c != null)
				currentHighSpn.setValue(c);
		}
		if(a == null || a.equals("powerStatus"))
			updatePowerStatus();
		if(a == null || a.equals("heatTapeStatus"))
			heatTapeStatus.setText(proxy.getHeatTapeStatus());
		if(a == null || a.equals("pixelStatus"))
			updatePixelStatus();
		if(a == null || a.equals("lampStatus"))
			updateLampStatus();
		if(a == null || a.equals("lightOutput")) {
			Integer o = proxy.getLightOutput();
			if(o != null)
				lightOutput.setText("" + o + "%");
			else
				lightOutput.setText(UNKNOWN);
			// FIXME: should check SONAR roles
			feedback.setEnabled(true);
		}
		if(a == null || a.equals("minCabinetTemp") ||
		   a.equals("maxCabinetTemp"))
		{
			cabinetTemp.setText(formatTemp(
				proxy.getMinCabinetTemp(),
				proxy.getMaxCabinetTemp()));
		}
		if(a == null || a.equals("minAmbientTemp") ||
		   a.equals("maxAmbientTemp"))
		{
			ambientTemp.setText(formatTemp(
				proxy.getMinAmbientTemp(),
				proxy.getMaxAmbientTemp()));
		}
		if(a == null || a.equals("minHousingTemp") ||
		   a.equals("maxHousingTemp"))
		{
			housingTemp.setText(formatTemp(
				proxy.getMinHousingTemp(),
				proxy.getMaxHousingTemp()));
		}
		if(a == null || a.equals("operation"))
			operation.setText(proxy.getOperation());
	}

	/** Select card on manufacturer panel for the given make */
	protected void updateMake(String m) {
		if(m.contains(MAKE_LEDSTAR.toUpperCase()))
			cards.show(card_panel, MAKE_LEDSTAR);
		else if(m.contains(MAKE_SKYLINE.toUpperCase()))
			cards.show(card_panel, MAKE_SKYLINE);
		else
			cards.show(card_panel, MAKE_GENERIC);
	}

	/** Update the power status */
	protected void updatePowerStatus() {
		String[] s = proxy.getPowerStatus();
		if(s != null && s.length == 3) {
			try {
				PowerTableModel m = new PowerTableModel(s);
				powerTable.setColumnModel(
					m.createColumnModel());
				powerTable.setModel(m);
			}
			catch(IOException e) {
				e.printStackTrace();
			}
		}
	}

	/** Update the pixel status */
	protected void updatePixelStatus() {
		updatePixelPanel(stuck_off_pnl);
		updatePixelPanel(stuck_on_pnl);
		String[] pixels = proxy.getPixelStatus();
		if(pixels != null && pixels.length == 2) {
			try {
				updatePixelStatus(pixels);
				return;
			}
			catch(IOException e) {
				e.printStackTrace();
			}
		}
		stuck_off_pnl.setGraphic(null);
		stuck_on_pnl.setGraphic(null);
		badPixels.setText(UNKNOWN);
	}

	/** Update the pixel status */
	protected void updatePixelStatus(String[] pixels) throws IOException {
		BitmapGraphic stuckOff = createBlankBitmap();
		BitmapGraphic stuckOn = createBlankBitmap();
		byte[] b_off = Base64.decode(pixels[DMS.STUCK_OFF_BITMAP]);
		if(b_off.length == stuckOff.length())
			stuckOff.setPixels(b_off);
		stuck_off_pnl.setGraphic(stuckOff);
		byte[] b_on = Base64.decode(pixels[DMS.STUCK_ON_BITMAP]);
		if(b_on.length == stuckOn.length())
			stuckOn.setPixels(b_on);
		stuck_on_pnl.setGraphic(stuckOn);
		int n_off = stuckOff.getLitCount();
		int n_on = stuckOn.getLitCount();
		badPixels.setText(String.valueOf(n_off + n_on));
	}

	/** Create a blank bitmap */
	protected BitmapGraphic createBlankBitmap() {
		Integer w = proxy.getWidthPixels();	// Avoid race
		Integer h = proxy.getHeightPixels();	// Avoid race
		if(w != null && h != null)
			return new BitmapGraphic(w, h);
		else
			return null;
	}

	/** Update the dimensions of a sign pixel panel */
	protected void updatePixelPanel(SignPixelPanel p) {
		updatePixelPhysical(p);
		updatePixelLogical(p);
		p.repaint();
	}

	/** Update the physical dimensions of a sign pixel panel */
	protected void updatePixelPhysical(SignPixelPanel p) {
		Integer w = proxy.getFaceWidth();
		Integer h = proxy.getFaceHeight();
		Integer hp = proxy.getHorizontalPitch();
		Integer vp = proxy.getVerticalPitch();
		Integer hb = proxy.getHorizontalBorder();
		Integer vb = proxy.getVerticalBorder();
		if(w != null && h != null && hp != null && vp != null &&
		   hb != null && vb != null)
		{
			p.setPhysicalDimensions(w, h, hb, vb, hp, vp);
		}
	}

	/** Update the logical dimensions of a sign pixel panel */
	protected void updatePixelLogical(SignPixelPanel p) {
		Integer wp = proxy.getWidthPixels();
		Integer hp = proxy.getHeightPixels();
		Integer cw = proxy.getCharWidthPixels();
		Integer ch = proxy.getCharHeightPixels();
		if(wp != null && hp != null && cw != null && ch != null)
			p.setLogicalDimensions(wp, hp, cw, ch);
	}

	/** Update the lamp status */
	protected void updateLampStatus() {
		String[] s = proxy.getLampStatus();
		if(s != null && s.length == 2) {
			try {
				LampTableModel m = new LampTableModel(s);
				lampTable.setAutoCreateColumnsFromModel(false);
				lampTable.setColumnModel(m.createColumnModel());
				lampTable.setModel(m);
				lampTable.setVisibleRowCount(8);
			}
			catch(IOException e) {
				e.printStackTrace();
			}
		}
	}
}
