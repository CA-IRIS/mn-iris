/*
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
extern crate honeybee;
extern crate gif;

use std::fs::File;
use std::io;
use gif::{Frame,Encoder,Repeat,SetParameter};
use honeybee::raster::{Mask,Raster};

/// Write raster to a GIF file.
///
/// * `filename` Name of file to write.
pub fn write_gif(rasters: &mut [Raster], filename: &str) -> io::Result<()> {
    let h = rasters[0].height() as u16;
    let w = rasters[0].width() as u16;
    let mut fl = File::create(filename)?;
    let mut enc = Encoder::new(&mut fl, w, h, &[])?;
    enc.set(Repeat::Infinite)?;
    for raster in rasters {
        let pix = raster.pixels();
        let mut frame = Frame::from_rgba(w, h, &mut pix[..]);
        frame.delay = 200; // 2 seconds
        enc.write_frame(&frame)?;
    }
    Ok(())
}

fn page1() -> Raster {
    let r = Raster::new(32, 32, [0, 0, 0, 255]);
    let mut m = Mask::new(r);
    m.circle(12f32, 12f32, 3f32);
    m.circle(20f32, 12f32, 3f32);
    m.circle(12f32, 20f32, 3f32);
    m.circle(20f32, 20f32, 3f32);
    m.composite([255, 208, 0]);
    m.clear();
    m.circle(16f32, 16f32, 3f32);
    m.composite([255, 0, 0]);
    m.into()
}

fn page2() -> Raster {
    let r = Raster::new(32, 32, [0, 0, 0, 255]);
    let mut m = Mask::new(r);
    m.circle(12f32, 12f32, 3f32);
    m.circle(20f32, 12f32, 3f32);
    m.circle(12f32, 20f32, 3f32);
    m.circle(20f32, 20f32, 3f32);
    m.composite([255, 208, 0]);
    m.into()
}

fn main() -> io::Result<()> {
    let mut rasters = Vec::new();
    rasters.push(page1());
    rasters.push(page2());
    write_gif(&mut rasters[..], "dots.gif")
}
