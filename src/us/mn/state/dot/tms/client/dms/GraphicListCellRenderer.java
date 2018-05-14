/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2018  Minnesota Department of Transportation
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

import java.awt.Component;
import java.awt.image.BufferedImage;
import javax.swing.ImageIcon;
import javax.swing.DefaultListCellRenderer;
import javax.swing.ListCellRenderer;
import javax.swing.JList;
import us.mn.state.dot.tms.Graphic;

/**
 * This class renders graphics in a JList.
 *
 * @author Douglas Lau
 */
public class GraphicListCellRenderer implements ListCellRenderer<Graphic> {

	/** Create an image */
	static private BufferedImage createImage(Object value) {
		return (value instanceof Graphic)
		      ? GraphicImage.create((Graphic) value)
		      : null;
	}

	/** Cell renderer */
	private final DefaultListCellRenderer cell =
		new DefaultListCellRenderer();

	/** Configure the renderer component */
	@Override
	public Component getListCellRendererComponent(
		JList<? extends Graphic> list, Graphic g, int index,
		boolean isSelected, boolean hasFocus)
	{
		String v = (g != null) ? Integer.toString(g.getGNumber()) : "";
		cell.getListCellRendererComponent(list, v, index, isSelected,
			hasFocus);
		BufferedImage im = createImage(g);
		cell.setIcon((im != null) ? new ImageIcon(im) : null);
		return cell;
	}
}
