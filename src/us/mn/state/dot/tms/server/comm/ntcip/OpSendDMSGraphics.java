/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2009-2015  Minnesota Department of Transportation
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
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;
import us.mn.state.dot.sched.TimeSteward;
import us.mn.state.dot.tms.Base64;
import us.mn.state.dot.tms.Graphic;
import us.mn.state.dot.tms.GraphicHelper;
import us.mn.state.dot.tms.server.DMSImpl;
import us.mn.state.dot.tms.server.comm.CommMessage;
import us.mn.state.dot.tms.server.comm.PriorityLevel;
import us.mn.state.dot.tms.server.comm.ntcip.mib1203.*;
import static us.mn.state.dot.tms.server.comm.ntcip.mib1203.MIB1203.*;
import us.mn.state.dot.tms.server.comm.snmp.ASN1Enum;
import us.mn.state.dot.tms.server.comm.snmp.ASN1Integer;
import us.mn.state.dot.tms.server.comm.snmp.ASN1OctetString;
import us.mn.state.dot.tms.server.comm.snmp.ASN1String;
import us.mn.state.dot.tms.server.comm.snmp.Counter;
import us.mn.state.dot.tms.server.comm.snmp.NoSuchName;
import us.mn.state.dot.tms.server.comm.snmp.SNMP;

/**
 * Operation to send a set of graphicss to a DMS controller.
 *
 * @author Douglas Lau
 */
public class OpSendDMSGraphics extends OpDMS {

	/** Make an ASN1Enum for DmsGraphicStatus */
	static private ASN1Enum<DmsGraphicStatus> makeStatus(int row) {
		return new ASN1Enum<DmsGraphicStatus>(DmsGraphicStatus.class,
			dmsGraphicStatus.node, row);
	}

	/** Color scheme supported */
	private final ASN1Enum<DmsColorScheme> color_scheme = new ASN1Enum<
		DmsColorScheme>(DmsColorScheme.class, dmsColorScheme.node);

	/** Number of graphics supported */
	private final ASN1Integer max_graphics = dmsGraphicMaxEntries.makeInt();

	/** Number of graphics defined in graphic table */
	private final ASN1Integer num_graphics = dmsGraphicNumEntries.makeInt();

	/** Maximum size of a graphic */
	private final ASN1Integer max_size = dmsGraphicMaxSize.makeInt();

	/** Available memory for storing graphics */
	private final Counter available_memory = new Counter(
		availableGraphicMemory.node);

	/** Size of graphic blocks (in bytes) */
	private final ASN1Integer block_size = dmsGraphicBlockSize.makeInt();

	/** Mapping of graphic numbers to indices (row in table) */
	private final TreeMap<Integer, Integer> num_2_row =
		new TreeMap<Integer, Integer>();

	/** Set of open rows in the graphic table */
	private final TreeSet<Integer> open_rows = new TreeSet<Integer>();

	/** Iterator of graphics to be sent to the sign */
	private Iterator<Graphic> graphic_iterator;

	/** Current graphic */
	private Graphic graphic;

	/** Graphic row for graphic table */
	private int row;

	/** Create a new operation to send graphics to a DMS */
	public OpSendDMSGraphics(DMSImpl d) {
		super(PriorityLevel.DOWNLOAD, d);
	}

	/** Create the second phase of the operation */
	@Override
	protected Phase phaseTwo() {
		return new QueryGraphicsConfiguration();
	}

	/** Phase to query the graphics configuration */
	private class QueryGraphicsConfiguration extends Phase {

		/** Query the graphics configuration */
		protected Phase poll(CommMessage mess) throws IOException {
			mess.add(color_scheme);
			mess.add(max_graphics);
			mess.add(block_size);
			try {
				mess.queryProps();
			}
			catch (NoSuchName e) {
				// Must be 1203v1 only (no graphics) ...
				logError("no graphics support -- aborted");
				return null;
			}
			logQuery(color_scheme);
			logQuery(max_graphics);
			logQuery(block_size);
			for (row = 1; row <= max_graphics.getInteger(); row++)
				open_rows.add(row);
			row = 1;
			lookupGraphics();
			return new QueryOptionalGraphics();
		}
	}

	/** Lookup all graphics which have the proper color scheme */
	private void lookupGraphics() {
		LinkedList<Graphic> graphics = new LinkedList<Graphic>();
		Iterator<Graphic> it = GraphicHelper.iterator();
		while (it.hasNext()) {
			Graphic g = it.next();
			Integer g_num = g.getGNumber();
			if (shouldSend(g_num, g)) {
				graphics.add(g);
				num_2_row.put(g_num, null);
			}
		}
		graphic_iterator = graphics.iterator();
	}

	/** Test if we should send the given graphic */
	private boolean shouldSend(Integer g_num, Graphic g) {
		Integer w = dms.getWidthPixels();
		Integer h = dms.getHeightPixels();
		int bpp = color_scheme.getEnum().bpp;
		return (g_num != null && w != null && h != null) &&
		       (g.getWidth() <= w) && (g.getHeight() <= h) &&
		       (g.getBpp() == 1 || g.getBpp() == bpp);
	}

	/** Phase to query optional graphics objects */
	private class QueryOptionalGraphics extends Phase {

		/** Query the optional graphics objects */
		protected Phase poll(CommMessage mess) throws IOException {
			mess.add(num_graphics);
			mess.add(max_size);
			mess.add(available_memory);
			try {
				mess.queryProps();
			}
			catch (NoSuchName e) {
				// Some manufacturers don't support these
				logError("optional graphics unsupported");
				return new QueryGraphicNumbers();
			}
			logQuery(num_graphics);
			logQuery(max_size);
			logQuery(available_memory);
			return new QueryGraphicNumbers();
		}
	}

	/** Phase to query all graphic numbers */
	private class QueryGraphicNumbers extends Phase {

		/** Query the graphic number for one graphic */
		protected Phase poll(CommMessage mess) throws IOException {
			ASN1Integer number = dmsGraphicNumber.makeInt(row);
			ASN1Enum<DmsGraphicStatus> status = makeStatus(row);
			mess.add(number);
			mess.add(status);
			mess.queryProps();
			logQuery(number);
			logQuery(status);
			Integer g_num = number.getInteger();
			if (num_2_row.containsKey(g_num)) {
				num_2_row.put(g_num, row);
				open_rows.remove(row);
			}
			if (row < max_graphics.getInteger()) {
				row++;
				return this;
			} else
				return populateNum2Row();
		}
	}

	/** Populate the num_2_row mapping */
	private Phase populateNum2Row() {
		for (Integer g_num: num_2_row.keySet()) {
			if (num_2_row.get(g_num) == null) {
				Integer r = open_rows.pollLast();
				if (r != null)
					num_2_row.put(g_num, r);
				else
					num_2_row.remove(g_num);
			}
		}
		return nextGraphicPhase();
	}

	/** Get the first phase of the next graphic */
	private Phase nextGraphicPhase() {
		while (graphic_iterator.hasNext()) {
			graphic = graphic_iterator.next();
			Integer g_num = graphic.getGNumber();
			if (num_2_row.containsKey(g_num)) {
				row = num_2_row.get(g_num);
				return new VerifyGraphic();
			}
			logError("Skipping graphic " + g_num);
		}
		return null;
	}

	/** Phase to verify a graphic */
	private class VerifyGraphic extends Phase {

		/** Verify a graphic */
		protected Phase poll(CommMessage mess) throws IOException {
			ASN1Integer gid = dmsGraphicID.makeInt(row);
			mess.add(gid);
			mess.queryProps();
			logQuery(gid);
			if (isIDCorrect(gid.getInteger())) {
				logError("Graphic valid");
				return nextGraphicPhase();
			} else
				return new QueryInitialStatus();
		}
	}

	/** Compare the graphic ID */
	private boolean isIDCorrect(int g) throws IOException {
		GraphicInfoList gil = new GraphicInfoList(graphic);
		return g == gil.getCrcSwapped();
	}

	/** Phase to query the initial graphic status */
	private class QueryInitialStatus extends Phase {

		/** Query the initial graphic status */
		protected Phase poll(CommMessage mess) throws IOException {
			ASN1Enum<DmsGraphicStatus> status = makeStatus(row);
			mess.add(status);
			mess.queryProps();
			logQuery(status);
			switch(status.getEnum()) {
			case notUsed:
				return new RequestModify();
			case modifying:
			case calculatingID:
			case readyForUse:
				return new InvalidateGraphic();
			default:
				logError("skipping graphic #" + row);
				return nextGraphicPhase();
			}
		}
	}

	/** Invalidate the graphic */
	private class InvalidateGraphic extends Phase {

		/** Invalidate the graphic entry in the graphic table */
		protected Phase poll(CommMessage mess) throws IOException {
			ASN1Enum<DmsGraphicStatus> status = makeStatus(row);
			status.setEnum(DmsGraphicStatus.notUsedReq);
			mess.add(status);
			logStore(status);
			mess.storeProps();
			return new RequestModify();
		}
	}

	/** Phase to request modifying the graphic */
	private class RequestModify extends Phase {

		/** Set the graphic status to modifyReq */
		protected Phase poll(CommMessage mess) throws IOException {
			ASN1Enum<DmsGraphicStatus> status = makeStatus(row);
			status.setEnum(DmsGraphicStatus.modifyReq);
			mess.add(status);
			logStore(status);
			mess.storeProps();
			return new VerifyStatusModifying();
		}
	}

	/** Phase to verify the graphic status is modifying */
	private class VerifyStatusModifying extends Phase {

		/** Verify the graphic status is modifying */
		protected Phase poll(CommMessage mess) throws IOException {
			ASN1Enum<DmsGraphicStatus> status = makeStatus(row);
			mess.add(status);
			mess.queryProps();
			logQuery(status);
			if (status.getEnum() != DmsGraphicStatus.modifying) {
				logError("graphic send aborted");
				return nextGraphicPhase();
			}
			return new CreateGraphic();
		}
	}

	/** Create the graphic */
	private class CreateGraphic extends Phase {

		/** Create a new graphic in the graphic table */
		protected Phase poll(CommMessage mess) throws IOException {
			ASN1Integer number = dmsGraphicNumber.makeInt(row);
			ASN1String name = new ASN1String(dmsGraphicName.node,
				row);
			ASN1Integer height = dmsGraphicHeight.makeInt(row);
			ASN1Integer width = dmsGraphicWidth.makeInt(row);
			ASN1Enum<DmsColorScheme> type = new ASN1Enum<
				DmsColorScheme>(DmsColorScheme.class,
				dmsGraphicType.node, row);
			ASN1Integer trans_enabled =
				dmsGraphicTransparentEnabled.makeInt(row);
			ASN1OctetString trans_color = new ASN1OctetString(
				dmsGraphicTransparentColor.node, row);
			number.setInteger(graphic.getGNumber());
			name.setString(graphic.getName());
			height.setInteger(graphic.getHeight());
			width.setInteger(graphic.getWidth());
			type.setEnum(DmsColorScheme.fromBpp(graphic.getBpp()));
			trans_enabled.setInteger(1);
			if (graphic.getBpp() == 24) {
				trans_color.setOctetString(
					new byte[] { 0, 0, 0 });
			} else
				trans_color.setOctetString(new byte[] { 0 });
			mess.add(number);
			mess.add(name);
			mess.add(height);
			mess.add(width);
			mess.add(type);
			mess.add(trans_enabled);
			mess.add(trans_color);
			logStore(number);
			logStore(name);
			logStore(height);
			logStore(width);
			logStore(type);
			logStore(trans_enabled);
			logStore(trans_color);
			mess.storeProps();
			return new SendGraphicBlock();
		}
	}

	/** Phase to send a block of a graphic */
	private class SendGraphicBlock extends Phase {

		/** Graphic bitmap */
		private final byte[] bitmap;

		/** Current block */
		private int block;

		/** Create a phase to send graphic blocks */
		private SendGraphicBlock() throws IOException {
			bitmap = Base64.decode(graphic.getPixels());
			block = 1;
		}

		/** Send a graphic block */
		protected Phase poll(CommMessage mess) throws IOException {
			ASN1OctetString block_bitmap = new ASN1OctetString(
				dmsGraphicBlockBitmap.node, row, block);
			block_bitmap.setOctetString(createBlock());
			mess.add(block_bitmap);
			logStore(block_bitmap);
			mess.storeProps();
			if (block * block_size.getInteger() < bitmap.length) {
				block++;
				if (block % 20 == 0 && !controller.isFailed())
					setSuccess(true);
				return this;
			} else
				return new ValidateGraphic();
		}

		/** Create a graphic block */
		private byte[] createBlock() {
			int bsize = block_size.getInteger();
			int pos = (block - 1) * bsize;
			int blen = Math.min(bsize, bitmap.length - pos);
			byte[] bdata = new byte[blen];
			System.arraycopy(bitmap, pos, bdata, 0, blen);
			return bdata;
		}
	}

	/** Phase to validate the graphic */
	private class ValidateGraphic extends Phase {

		/** Validate a graphic entry in the graphic table */
		protected Phase poll(CommMessage mess) throws IOException {
			ASN1Enum<DmsGraphicStatus> status = makeStatus(row);
			status.setEnum(DmsGraphicStatus.readyForUseReq);
			mess.add(status);
			logStore(status);
			mess.storeProps();
			return new VerifyStatusReadyForUse();
		}
	}

	/** Phase to verify the graphic status is ready for use */
	private class VerifyStatusReadyForUse extends Phase {

		/** Time to stop checking if the graphic is ready for use */
		private final long expire = TimeSteward.currentTimeMillis() +
			10 * 1000;

		/** Verify the graphic status is ready for use */
		protected Phase poll(CommMessage mess) throws IOException {
			ASN1Enum<DmsGraphicStatus> status = makeStatus(row);
			mess.add(status);
			mess.queryProps();
			logQuery(status);
			if (status.getEnum() == DmsGraphicStatus.readyForUse)
				return new VerifyGraphicFinal();
			if (TimeSteward.currentTimeMillis() > expire) {
				logError("graphic status timeout expired -- " +
					"aborted");
				return nextGraphicPhase();
			} else
				return this;
		}
	}

	/** Phase to verify a graphic after validating */
	private class VerifyGraphicFinal extends Phase {

		/** Verify a graphic */
		protected Phase poll(CommMessage mess) throws IOException {
			ASN1Integer gid = dmsGraphicID.makeInt(row);
			mess.add(gid);
			mess.queryProps();
			logQuery(gid);
			if (!isIDCorrect(gid.getInteger())) {
				setErrorStatus("Graphic " +graphic.getGNumber()+
					" ID incorrect after validating");
			}
			return nextGraphicPhase();
		}
	}
}
