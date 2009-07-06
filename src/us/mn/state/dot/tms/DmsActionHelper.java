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
package us.mn.state.dot.tms;

import us.mn.state.dot.sonar.Checker;

/**
 * Helper class for DMS actions.
 *
 * @author Douglas Lau
 */
public class DmsActionHelper extends BaseHelper {

	/** Don't allow instances to be created */
	private DmsActionHelper() {
		assert false;
	}

	/** Find DMS actions using a Checker */
	static public DmsAction find(final Checker<DmsAction> checker) {
		return (DmsAction)namespace.findObject(DmsAction.SONAR_TYPE, 
			checker);
	}

	/** Lookup the DMS action with the specified name */
	static public DmsAction lookup(String name) {
		return (DmsAction)namespace.lookupObject(DmsAction.SONAR_TYPE,
			name);
	}
}
