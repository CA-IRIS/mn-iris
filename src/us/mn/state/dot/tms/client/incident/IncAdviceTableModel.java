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
package us.mn.state.dot.tms.client.incident;

import java.awt.Component;
import java.awt.Font;
import java.util.ArrayList;
import java.util.Comparator;
import javax.swing.DefaultCellEditor;
import javax.swing.JComboBox;
import javax.swing.JTable;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.TableCellEditor;
import javax.swing.table.TableCellRenderer;
import us.mn.state.dot.tms.IncAdvice;
import us.mn.state.dot.tms.IncRange;
import us.mn.state.dot.tms.LaneType;
import us.mn.state.dot.tms.client.Session;
import us.mn.state.dot.tms.client.proxy.ProxyColumn;
import us.mn.state.dot.tms.client.proxy.ProxyDescriptor;
import us.mn.state.dot.tms.client.proxy.ProxyTableModel;
import us.mn.state.dot.tms.utils.MultiString;

/**
 * Table model for incident advices.
 *
 * @author Douglas Lau
 */
public class IncAdviceTableModel extends ProxyTableModel<IncAdvice> {

	/** Create a proxy descriptor */
	static public ProxyDescriptor<IncAdvice> descriptor(Session s) {
		return new ProxyDescriptor<IncAdvice>(
			s.getSonarState().getIncCache().getIncAdvices(),
			false,	/* has_properties */
			true,	/* has_create_delete */
			false	/* has_name */
		);
	}

	/** Renderer for lane impact in a table cell */
	static private class ImpactCellRenderer extends DefaultTableCellRenderer
	{
		@Override
		public Component getTableCellRendererComponent(JTable table,
			Object value, boolean isSelected, boolean hasFocus,
			int row, int column)
		{
			Component c = super.getTableCellRendererComponent(table,
				value, isSelected, hasFocus, row, column);
			Font f = c.getFont();
			int sz = f.getSize();
			c.setFont(new Font(Font.MONOSPACED, Font.BOLD, sz));
			return c;
		}
	}

	/** Create the columns in the model */
	@Override
	protected ArrayList<ProxyColumn<IncAdvice>> createColumns() {
		ArrayList<ProxyColumn<IncAdvice>> cols =
			new ArrayList<ProxyColumn<IncAdvice>>(6);
		cols.add(new ProxyColumn<IncAdvice>("incident.range", 96) {
			public Object getValueAt(IncAdvice adv) {
				return IncRange.fromOrdinal(adv.getRange());
			}
			public boolean isEditable(IncAdvice adv) {
				return canWrite(adv);
			}
			public void setValueAt(IncAdvice adv, Object value) {
				if (value instanceof IncRange) {
					IncRange r = (IncRange) value;
					adv.setRange(r.ordinal());
				}
			}
			protected TableCellEditor createCellEditor() {
				JComboBox<IncRange> cbx = new JComboBox
					<IncRange>(IncRange.values());
				return new DefaultCellEditor(cbx);
			}
		});
		cols.add(new ProxyColumn<IncAdvice>("incident.lane_type", 96) {
			public Object getValueAt(IncAdvice adv) {
				return LaneType.fromOrdinal(adv.getLaneType());
			}
			public boolean isEditable(IncAdvice adv) {
				return canWrite(adv);
			}
			public void setValueAt(IncAdvice adv, Object value) {
				if (value instanceof LaneType) {
					LaneType lt = (LaneType) value;
					adv.setLaneType((short) lt.ordinal());
				}
			}
			protected TableCellEditor createCellEditor() {
				return new DefaultCellEditor(IncidentCreator
					.createLaneTypeCombo());
			}
		});
		cols.add(new ProxyColumn<IncAdvice>("incident.impact", 128) {
			public Object getValueAt(IncAdvice adv) {
				return adv.getImpact();
			}
			public boolean isEditable(IncAdvice adv) {
				return canWrite(adv);
			}
			public void setValueAt(IncAdvice adv, Object value) {
				adv.setImpact(value.toString());
			}
			protected TableCellRenderer createCellRenderer() {
				return new ImpactCellRenderer();
			}
		});
		cols.add(new ProxyColumn<IncAdvice>("incident.clear", 50,
			Boolean.class)
		{
			public Object getValueAt(IncAdvice adv) {
				return adv.getCleared();
			}
			public boolean isEditable(IncAdvice adv) {
				return canWrite(adv);
			}
			public void setValueAt(IncAdvice adv, Object value) {
				if (value instanceof Boolean) {
					Boolean b = (Boolean) value;
					adv.setCleared(b);
				}
			}
		});
		cols.add(new ProxyColumn<IncAdvice>("dms.multi.string", 300) {
			public Object getValueAt(IncAdvice adv) {
				return adv.getMulti();
			}
			public boolean isEditable(IncAdvice adv) {
				return canWrite(adv);
			}
			public void setValueAt(IncAdvice adv, Object value){
				adv.setMulti(new MultiString(value.toString())
					.normalize());
			}
		});
		cols.add(new ProxyColumn<IncAdvice>("dms.multi.abbrev", 150) {
			public Object getValueAt(IncAdvice adv) {
				return adv.getAbbrev();
			}
			public boolean isEditable(IncAdvice adv) {
				return canWrite(adv);
			}
			public void setValueAt(IncAdvice adv, Object value) {
				String a = new MultiString(value.toString())
					.normalize();
				adv.setAbbrev((a.length() > 0) ? a : null);
			}
		});
		return cols;
	}

	/** Create a new table model.
	 * @param s Session */
	public IncAdviceTableModel(Session s) {
		super(s, descriptor(s), 12, 20);
	}

	/** Get a proxy comparator */
	@Override
	protected Comparator<IncAdvice> comparator() {
		return new Comparator<IncAdvice>() {
			public int compare(IncAdvice adv0, IncAdvice adv1) {
				int lt0 = adv0.getLaneType();
				int lt1 = adv0.getLaneType();
				if (lt0 != lt1)
					return lt0 - lt1;
				String imp0 = adv0.getImpact();
				String imp1 = adv1.getImpact();
				if (imp0.length() != imp1.length())
					return imp0.length() - imp1.length();
				int c = imp0.compareTo(imp1);
				if (c != 0)
					return c;
				int r0 = adv0.getRange();
				int r1 = adv1.getRange();
				if (r0 != r1)
					return r0 - r1;
				return adv0.getName().compareTo(adv1.getName());
			}
		};
	}

	/** Create a new incident advice */
	@Override
	public void createObject(String name_ignore) {
		String name = createUniqueName();
		if (name != null)
			descriptor.cache.createObject(name);
	}

	/** Create a unique incident advice name */
	private String createUniqueName() {
		for (int uid = 1; uid <= 99999; uid++) {
			String n = String.format("iadv_%05d", uid);
			if (descriptor.cache.lookupObject(n) == null)
				return n;
		}
		return null;
	}
}
