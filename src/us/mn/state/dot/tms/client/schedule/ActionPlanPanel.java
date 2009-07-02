/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2009  Minnesota Department of Transportation
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
package us.mn.state.dot.tms.client.schedule;

import java.awt.FlowLayout;
import javax.swing.JButton;
import javax.swing.JPanel;
import javax.swing.JTabbedPane;
import javax.swing.ListSelectionModel;
import us.mn.state.dot.sched.ActionJob;
import us.mn.state.dot.sched.ListSelectionJob;
import us.mn.state.dot.sonar.Namespace;
import us.mn.state.dot.sonar.User;
import us.mn.state.dot.sonar.client.TypeCache;
import us.mn.state.dot.tms.ActionPlan;
import us.mn.state.dot.tms.DmsAction;
import us.mn.state.dot.tms.TimeAction;
import us.mn.state.dot.tms.client.Session;
import us.mn.state.dot.tms.client.toast.FormPanel;
import us.mn.state.dot.tms.client.widget.ZTable;

/**
 * A form for displaying and editing action plans.
 *
 * @author Douglas Lau
 */
public class ActionPlanPanel extends FormPanel {

	/** Table row height */
	static protected final int ROW_HEIGHT = 20;

	/** Table model for action plans */
	protected final ActionPlanModel p_model;

	/** Table to hold the action plans */
	protected final ZTable p_table = new ZTable();

	/** Button to delete the selected action plan */
	protected final JButton del_p_btn = new JButton("Delete Plan");

	/** Table model for time plans */
	protected TimeActionModel t_model;

	/** Table to hold time actions */
	protected final ZTable t_table = new ZTable();

	/** Button to delete the selected time action */
	protected final JButton del_t_btn = new JButton("Delete");

	/** Table model for DMS actions */
	protected DmsActionModel d_model;

	/** Table to hold DMS actions */
	protected final ZTable d_table = new ZTable();

	/** Button to delete the selected DMS action */
	protected final JButton del_d_btn = new JButton("Delete");

	/** Tabbed pane */
	protected final JTabbedPane tab = new JTabbedPane();

	/** SONAR namespace */
	protected final Namespace namespace;

	/** Logged-in user */
	protected final User user;

	/** Action plan type cache */
	protected final TypeCache<ActionPlan> cache;

	/** Time action type cache */
	protected final TypeCache<TimeAction> t_cache;

	/** DMS action type cache */
	protected final TypeCache<DmsAction> d_cache;

	/** Create a new action plan panel */
	public ActionPlanPanel(Session s) {
		super(true);
		namespace = s.getSonarState().getNamespace();
		user = s.getUser();
		cache = s.getSonarState().getActionPlans();
		t_cache = s.getSonarState().getTimeActions();
		d_cache = s.getSonarState().getDmsActions();
		p_model = new ActionPlanModel(cache, namespace, user);
	}

	/** Initializze the widgets on the panel */
	protected void initialize() {
		addActionPlanJobs();
		addTimeActionJobs();
		addDmsActionJobs();
		p_table.setModel(p_model);
		p_table.setAutoCreateColumnsFromModel(false);
		p_table.setColumnModel(ActionPlanModel.createColumnModel());
		p_table.setRowHeight(ROW_HEIGHT);
		p_table.setVisibleRowCount(10);
		addRow(p_table);
		addRow(del_p_btn);
		del_p_btn.setEnabled(false);
		JPanel panel = new JPanel(new FlowLayout());
		FormPanel t_panel = new FormPanel(true);
		t_table.setAutoCreateColumnsFromModel(false);
		t_table.setColumnModel(TimeActionModel.createColumnModel());
		t_table.setRowHeight(ROW_HEIGHT);
		t_table.setVisibleRowCount(8);
		t_panel.addRow(t_table);
		t_panel.addRow(del_t_btn);
		del_t_btn.setEnabled(false);
		panel.add(t_panel);
		FormPanel d_panel = new FormPanel(true);
		d_table.setAutoCreateColumnsFromModel(false);
		d_table.setColumnModel(DmsActionModel.createColumnModel());
		d_table.setRowHeight(ROW_HEIGHT);
		d_table.setVisibleRowCount(6);
		d_panel.addRow(d_table);
		d_panel.addRow(del_d_btn);
		del_d_btn.setEnabled(false);
		panel.add(d_panel);
		tab.add("DMS Actions", d_panel);
		panel.add(tab);
		addRow(panel);
	}

	/** Add jobs for action plan table */
	protected void addActionPlanJobs() {
		final ListSelectionModel sm = p_table.getSelectionModel();
		sm.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		new ListSelectionJob(this, sm) {
			public void perform() {
				if(!event.getValueIsAdjusting())
					selectActionPlan();
			}
		};
		new ActionJob(this, del_p_btn) {
			public void perform() throws Exception {
				int row = sm.getMinSelectionIndex();
				if(row >= 0)
					p_model.deleteRow(row);
			}
		};
	}

	/** Add jobs for time action table */
	protected void addTimeActionJobs() {
		final ListSelectionModel sm = t_table.getSelectionModel();
		sm.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		new ListSelectionJob(this, sm) {
			public void perform() {
				if(!event.getValueIsAdjusting())
					selectTimeAction();
			}
		};
		new ActionJob(this, del_t_btn) {
			public void perform() throws Exception {
				int row = sm.getMinSelectionIndex();
				if(row >= 0)
					t_model.deleteRow(row);
			}
		};
	}

	/** Add jobs for DMS action table */
	protected void addDmsActionJobs() {
		final ListSelectionModel sm = d_table.getSelectionModel();
		sm.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		new ListSelectionJob(this, sm) {
			public void perform() {
				if(!event.getValueIsAdjusting())
					selectDmsAction();
			}
		};
		new ActionJob(this, del_d_btn) {
			public void perform() throws Exception {
				int row = sm.getMinSelectionIndex();
				if(row >= 0)
					d_model.deleteRow(row);
			}
		};
	}

	/** Dispose of the form */
	protected void dispose() {
		p_model.dispose();
		if(t_model != null) {
			t_model.dispose();
			t_model = null;
		}
		if(d_model != null) {
			d_model.dispose();
			d_model = null;
		}
	}

	/** Change the selected action plan */
	protected void selectActionPlan() {
		int row = p_table.getSelectedRow();
		ActionPlan ap = p_model.getProxy(row);
		del_p_btn.setEnabled(p_model.canRemove(row));
		del_t_btn.setEnabled(false);
		TimeActionModel ot_model = t_model;
		t_model = new TimeActionModel(t_cache, ap, namespace, user);
		t_table.setModel(t_model);
		if(ot_model != null)
			ot_model.dispose();
		del_d_btn.setEnabled(false);
		DmsActionModel od_model = d_model;
		d_model = new DmsActionModel(d_cache, ap, namespace, user);
		d_table.setModel(d_model);
		if(od_model != null)
			od_model.dispose();
	}

	/** Change the selected time action */
	protected void selectTimeAction() {
		int row = t_table.getSelectedRow();
		del_t_btn.setEnabled(t_model.canRemove(row));
	}

	/** Change the selected DMS action */
	protected void selectDmsAction() {
		int row = d_table.getSelectedRow();
		del_d_btn.setEnabled(d_model.canRemove(row));
	}
}
