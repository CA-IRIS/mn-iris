/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2009-2018  Minnesota Department of Transportation
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
package us.mn.state.dot.tms.client.lcs;

import java.awt.Color;
import java.util.Comparator;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPopupMenu;
import javax.swing.ListCellRenderer;
import us.mn.state.dot.tms.CorridorBase;
import us.mn.state.dot.tms.DMS;
import us.mn.state.dot.tms.GeoLoc;
import us.mn.state.dot.tms.GeoLocHelper;
import us.mn.state.dot.tms.ItemStyle;
import us.mn.state.dot.tms.LaneConfiguration;
import us.mn.state.dot.tms.LCSArray;
import us.mn.state.dot.tms.LCSArrayHelper;
import static us.mn.state.dot.tms.R_Node.MAX_LANES;
import us.mn.state.dot.tms.client.Session;
import us.mn.state.dot.tms.client.map.Style;
import us.mn.state.dot.tms.client.proxy.DeviceManager;
import us.mn.state.dot.tms.client.proxy.GeoLocManager;
import us.mn.state.dot.tms.client.proxy.ProxyDescriptor;
import us.mn.state.dot.tms.client.proxy.ProxyJList;
import us.mn.state.dot.tms.client.proxy.ProxyTheme;
import us.mn.state.dot.tms.client.proxy.StyleListModel;
import us.mn.state.dot.tms.client.proxy.WorkRequestAction;
import us.mn.state.dot.tms.geo.Position;
import us.mn.state.dot.tms.utils.I18N;

/**
 * The LCSArrayManager class provides proxies for LCSArray objects.
 *
 * @author Douglas Lau
 */
public class LCSArrayManager extends DeviceManager<LCSArray> {

	/** Create a proxy descriptor */
	static public ProxyDescriptor<LCSArray> descriptor(final Session s) {
		return new ProxyDescriptor<LCSArray>(
			s.getSonarState().getLcsCache().getLCSArrays(), true
		) {
			@Override
			public LCSArrayProperties createPropertiesForm(
				LCSArray la)
			{
				return new LCSArrayProperties(s, la);
			}
			@Override
			public LcsForm makeTableForm() {
				return new LcsForm(s);
			}
		};
	}

	/** Action to blank the selected LCS array */
	private BlankLcsAction blankAction;

	/** Set the blank LCS action */
	public void setBlankAction(BlankLcsAction a) {
		blankAction = a;
	}

	/** Create a new LCS array manager */
	public LCSArrayManager(Session s, GeoLocManager lm) {
		super(s, lm, descriptor(s), 14);
	}

	/** Create an LCS map tab */
	@Override
	public LcsTab createTab() {
		return new LcsTab(session, this);
	}

	/** Create a theme for LCS arrays */
	@Override
	protected ProxyTheme<LCSArray> createTheme() {
		ProxyTheme<LCSArray> theme = new ProxyTheme<LCSArray>(this,
			new LcsMarker());
		theme.addStyle(ItemStyle.AVAILABLE, ProxyTheme.COLOR_AVAILABLE);
		theme.addStyle(ItemStyle.DEPLOYED, ProxyTheme.COLOR_DEPLOYED);
		theme.addStyle(ItemStyle.SCHEDULED, ProxyTheme.COLOR_SCHEDULED);
		theme.addStyle(ItemStyle.MAINTENANCE,
			ProxyTheme.COLOR_UNAVAILABLE);
		theme.addStyle(ItemStyle.FAILED, ProxyTheme.COLOR_FAILED);
		theme.addStyle(ItemStyle.ALL);
		return theme;
	}

	/** Create a list cell renderer */
	@Override
	public ListCellRenderer<LCSArray> createCellRenderer() {
		return new LCSArrayCellRenderer(this);
	}

	/** Comparator for ordering LCS arrays */
	private final Comparator<LCSArray> lcs_comparator =
		new Comparator<LCSArray>()
	{
		public int compare(LCSArray l0, LCSArray l1) {
			// sort downstream to upstream
			return l1.getName().compareTo(l0.getName());
		}
	};

	/** Create a style list model for the given symbol */
	@Override
	protected StyleListModel<LCSArray> createStyleListModel(Style sty) {
		return new StyleListModel<LCSArray>(this, sty.toString()) {
			@Override
			protected Comparator<LCSArray> comparator() {
				return lcs_comparator;
			}
		};
	}

	/** Create a proxy JList */
	@Override
	public ProxyJList<LCSArray> createList() {
		ProxyJList<LCSArray> list = super.createList();
		list.setLayoutOrientation(JList.VERTICAL_WRAP);
		list.setVisibleRowCount(0);
		return list;
	}

	/** Fill single selection popup */
	@Override
	protected void fillPopupSingle(JPopupMenu p, LCSArray la) {
		if (LCSArrayHelper.isDeployed(la) && blankAction != null) {
			p.add(blankAction);
			p.addSeparator();
		}
	}

	/** Fill single selection work request popup */
	@Override
	protected void fillPopupWorkReq(JPopupMenu p, LCSArray la) {
		for (int i = 1; i <= MAX_LANES; i++) {
			DMS dms = LCSArrayHelper.lookupDMS(la, i);
			if (dms != null) {
				p.add(new WorkRequestAction<DMS>(dms,
					dms.getGeoLoc()));
			}
		}
		p.addSeparator();
	}

	/** Create a popup menu for multiple objects */
	@Override
	protected JPopupMenu createPopupMulti(int n_selected) {
		JPopupMenu p = new JPopupMenu();
		p.add(new JLabel(I18N.get("lcs_array.title") + ": " +
			n_selected));
		p.addSeparator();
		return p;
	}

	/** Find the map geo location for a proxy */
	@Override
	protected GeoLoc getGeoLoc(final LCSArray proxy) {
		return LCSArrayHelper.lookupGeoLoc(proxy);
	}

	/** Get the lane configuration at an LCS array */
	public LaneConfiguration laneConfiguration(LCSArray proxy) {
		GeoLoc loc = LCSArrayHelper.lookupGeoLoc(proxy);
		CorridorBase cor = session.getR_NodeManager().lookupCorridor(
			loc);
		if(cor != null) {
			Position pos = GeoLocHelper.getWgs84Position(loc);
			if(pos != null)
				return cor.laneConfiguration(pos);
		}
		return new LaneConfiguration(0, 0);
	}
}
