/*
 * IRIS -- Intelligent Roadway Information System
 * Copyright (C) 2007-2018  Minnesota Department of Transportation
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
package us.mn.state.dot.tms.server;

import java.util.ArrayList;
import us.mn.state.dot.tms.GeoLoc;
import us.mn.state.dot.tms.LaneType;
import us.mn.state.dot.tms.units.Distance;

/**
 * A route is a list of "route legs" from an origin to a destination on a
 * roadway network.
 *
 * @author Douglas Lau
 */
public class Route {

	/** Penalty (in goodness) for each leg in a route */
	static private final float LEG_PENALTY = 0.25f;

	/** Route destination */
	private final GeoLoc dest;

	/** Final leg of route */
	public final RouteLeg leg;

	/** Create a new route */
	private Route(GeoLoc dst, RouteLeg lg) {
		dest = dst;
		leg = lg;
	}

	/** Create a new route */
	public Route(GeoLoc dst) {
		this(dst, null);
	}

	/** Create an extended route.
	 * @param c Corridor of leg.
	 * @param od O/D pair of leg.
	 * @return Extended route with new leg. */
	public Route createExtended(Corridor c, ODPair od) {
		RouteLeg lg = RouteLeg.create(c, od, leg);
		return (lg != null) ? new Route(dest, lg) : null;
	}

	/** Get the destination */
	public GeoLoc getDestination() {
		return dest;
	}

	/** Get the number of legs */
	public int legCount() {
		int i = 0;
		for (RouteLeg lg = leg; lg != null; lg = lg.prev)
			i++;
		return i;
	}

	/** Get the number of turns in the route */
	public int getTurns() {
		int t = 0;
		for (RouteLeg lg = leg; lg != null; lg = lg.prev) {
			if (lg.hasTurn())
				t++;
		}
		return t;
	}

	/** Get the "only" corridor (if the route is just a single corridor) */
	private Corridor getOnlyCorridor() {
		return (legCount() == 1) ? leg.corridor : null;
	}

	/** Is the route confined to the same single corridor? */
	private boolean isSameCorridor(Corridor c) {
		return (c != null) && (getOnlyCorridor() == c);
	}

	/** Is another route confined to the same single corridor? */
	public boolean isSameCorridor(Route r) {
		return (r != null) && isSameCorridor(r.getOnlyCorridor());
	}

	/** Get the route distance.
	 * @return Total route distance. */
	public Distance getDistance() {
		Distance d = new Distance(0);
		for (RouteLeg lg = leg; lg != null; lg = lg.prev)
			d = d.add(lg.getDistance());
		return d;
	}

	/** Get the goodness rating (lower is better) */
	public float getGoodness() {
		return getDistance().asFloat(Distance.Units.MILES) +
		       legCount() * LEG_PENALTY;
	}

	/** Get a set of vehicle samplers on route */
	public SamplerSet getSamplerSet(LaneType lt) {
		ArrayList<VehicleSampler> vs = new ArrayList<VehicleSampler>();
		for (RouteLeg lg = leg; lg != null; lg = lg.prev)
			vs.addAll(lg.lookupSamplers(lt));
		return new SamplerSet(vs);
	}

	/** Get a string representation of the route */
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append(getDistance());
		sb.append(", ");
		sb.append(getTurns());
		sb.append(" turns, ");
		sb.append(getGoodness());
		sb.append(" goodness,");
		for (RouteLeg lg = leg; lg != null; lg = lg.prev) {
			sb.append(' ');
			sb.append(lg.toString());
		}
		return sb.toString();
	}
}
