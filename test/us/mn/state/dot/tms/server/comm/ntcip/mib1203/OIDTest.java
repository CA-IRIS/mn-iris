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
package us.mn.state.dot.tms.server.comm.ntcip.mib1203;

import junit.framework.TestCase;

/** 
 * OID tests.
 *
 * @author Doug Lau
 */
public class OIDTest extends TestCase {

	/** constructor */
	public OIDTest(String name) {
		super(name);
	}

	/** test cases */
	public void test() {
		int[] oid = new VmsVerticalPitch().getOID();
		assertTrue(java.util.Arrays.equals(oid, new int[] {
			1, 3, 6, 1, 4, 1, 1206, 4, 2, 3, 2, 6, 0
		}));
	}
}
