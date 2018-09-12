\set ON_ERROR_STOP
SET SESSION AUTHORIZATION 'tms';
BEGIN;

INSERT INTO iris.font (name, f_number, height, width, line_spacing,
    char_spacing, version_id) VALUES ('26_full', 20, 26, 0, 9, 5, 0);

INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_32', 1, 26, 3, 'AAAAAAAAAAAAAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_32', '26_full', 32, '26_full_32');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_33', 1, 26, 3, '////+22222A//A==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_33', '26_full', 33, '26_full_33');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_34', 1, 26, 6, 'zzzzzzzzzAAAAAAAAAAAAAAAAAA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_34', '26_full', 34, '26_full_34');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_35', 1, 26, 15, 'AAAAAAAAMYBjAMYBjAMYBjAc4/////DGAYwDGAYw/////HOAxgGMAxgGMAxgGMAAAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_35', '26_full', 35, '26_full_35');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_36', 1, 26, 14, 'AwAMAf4P/Ht7zO4x+MfjAcwH8A/wB/AN4DPAxwMMDDww+MNjHczz/4f8AwAMAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_36', '26_full', 36, '26_full_36');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_37', 1, 26, 19, 'AAAHgGH4DHODDDBhhhgwwwYYwMMYGGYDDMBzsAfmAHiPADPwBucBmGAzDAxhgYwwYYYMMMMGGGDn
GA/DAPA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_37', '26_full', 37, '26_full_37');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_38', 1, 26, 18, 'A8AD+AD/AHHAHDgGDgHDgHDAHHADuAB8AB4AD4APcMOeccOcYHc4H44D44B44B4cB4eH8P/eP+OD
4PA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_38', '26_full', 38, '26_full_38');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_39', 1, 26, 2, '///AAAAAAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_39', '26_full', 39, '26_full_39');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_40', 1, 26, 6, 'DGGMMMYYYYwwwwwwYYYYMMMGGDA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_40', '26_full', 40, '26_full_40');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_41', 1, 26, 6, 'wYYMMMGGGGDDDDDDGGGGMMMYYwA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_41', '26_full', 41, '26_full_41');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_42', 1, 26, 10, 'DAMIxzPt3+PweD8f7t8zjEMAwAAAAAAAAAAAAAAAAAAA');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_42', '26_full', 42, '26_full_42');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_43', 1, 26, 14, 'AAAAAAAAAAAADAAwAMADAAwAMADAAwP////AwAMADAAwAMADAAwAMAAAAAAAAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_43', '26_full', 43, '26_full_43');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_44', 1, 26, 3, 'AAAAAAAAAAH/eA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_44', '26_full', 44, '26_full_44');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_45', 1, 26, 8, 'AAAAAAAAAAAAAAAAAP//AAAAAAAAAAAAAAA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_45', '26_full', 45, '26_full_45');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_46', 1, 26, 3, 'AAAAAAAAAAA//A==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_46', '26_full', 46, '26_full_46');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_47', 1, 26, 9, 'AYDAYGAwGBgMBgMDAYDAwGAwMBgMBgYDAYGAwGAA');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_47', '26_full', 47, '26_full_47');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_48', 1, 26, 15, 'AAAPgH+A/4OHjgccBzgOYB3AO4B/AH4A/AH4A/AH4B/AOYBzgOcBjgcOHh/4H+APgA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_48', '26_full', 48, '26_full_48');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_49', 1, 26, 8, 'AAcHBw////8HBwcHBwcHBwcHBwcHBwcHBwc=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_49', '26_full', 49, '26_full_49');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_50', 1, 26, 14, 'AAAfAf8P/nh5wPYB2AfgH4BwAcAPADgDwB8B8A+AeAPAHgBwAYAOAD//////8A==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_50', '26_full', 50, '26_full_50');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_51', 1, 26, 14, 'AAA/Af8P/nh5wOYB2AdgHABgA4D8A+AP4AfABwAcAD4A+APgHcB3g4/+H/A/AA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_51', '26_full', 51, '26_full_51');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_52', 1, 26, 14, 'AAABwA8APAHwD8A3AdwGcDHBxwYcOHDBxwc4HMBz//////8AcAHABwAcAHABwA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_52', '26_full', 52, '26_full_52');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_53', 1, 26, 14, 'AAD/4/+P/nABwAcAHABwAY4G/h/8eHnA8AHABwAcAHAB+AfgH4DnB5/8P+A+AA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_53', '26_full', 53, '26_full_53');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_54', 1, 26, 14, 'AAAfAP8H/jw44HcB3AdgAYAOfDv8//vg7wH8B+AfgD4A2AdwHcBzg4/8H+AfAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_54', '26_full', 54, '26_full_54');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_55', 1, 26, 14, 'AAP//////wAcAGADgAwAcAOADgBwAcAGADgAwAcAHABwA4AOADgA4AcAHABwAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_55', '26_full', 55, '26_full_55');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_56', 1, 26, 14, 'AAAfAf8P/Dh5wOcB3AdwHcDnh4/8D+D/x4ecB+AfgH4A+APgHcB3g4/+H/A/AA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_56', '26_full', 56, '26_full_56');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_57', 1, 26, 14, 'AAAfAf4P/Hh5wOYB+AfgH4B+AfgHcD3h8/7H9w+cAHAB+AZgOcDnBw/4P+A+AA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_57', '26_full', 57, '26_full_57');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_58', 1, 26, 3, 'AAAH/4AAAAH/eA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_58', '26_full', 58, '26_full_58');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_59', 1, 26, 3, 'AAAH/4AAAH/4AA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_59', '26_full', 59, '26_full_59');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_60', 1, 26, 15, 'AAAAAAAAAAAAAAAAAYAPAHwD4B8A+AfAHgA8AD4AHwAPgAfAA+AB4ADAAAAAAAAAAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_60', '26_full', 60, '26_full_60');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_61', 1, 26, 13, 'AAAAAAAAAAAAAAAAAAAH//////AAAAAAAAD//////gAAAAAAAAAAAAAAAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_61', '26_full', 61, '26_full_61');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_62', 1, 26, 15, 'AAAAAAAAAAAAAAAwAHgAfAA+AB8AD4AHwAPAB4A+AfAPgHwD4A8AGAAAAAAAAAAAAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_62', '26_full', 62, '26_full_62');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_63', 1, 26, 13, 'D4H+H/jh7gdwGwD4BwAwA4A8AcAcAcAMAOAGADABgAAAAAAAGADABgAwAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_63', '26_full', 63, '26_full_63');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_64', 1, 26, 22, 'AH4AD/4AeDwDgDgcAHDgQOMH3Zx/5mHHjY4ONjA4+cDD5wMPmAxuYGGZgYZnDjGceYM//Az94BhA
MHABwOAOAfDwA/+AAfgA');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_64', '26_full', 64, '26_full_64');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_65', 1, 26, 18, 'AeAAeAAeAA/AA/AA3ABzgBzgBjgDjgDhwDhwDBwHA4HA4H/4P/8P/8MAccAccAOcAO4AO4AH4AHw
AHA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_65', '26_full', 65, '26_full_65');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_66', 1, 26, 17, '//B//j//nAPOAOcAe4AdwA7gDnAHOAcf/w//x//zgD3ADuAHcAH4APwAfgB3ADuAPf/8//x/+AA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_66', '26_full', 66, '26_full_66');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_67', 1, 26, 18, 'AfAB/wD/4Hx8PAeOAOeAHcAHcAAcAA4AA4AA4AA4AA4AA4AAcAHcAHcAHeAOOAOPAcHx8D/4B/wA
fAA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_67', '26_full', 67, '26_full_67');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_68', 1, 26, 17, '/+B//D//HAfOAecAe4AdwA7gA/AB+AD8AH4APwAfgA/AB+AD8AH4AdwA7gD3APOA8f/4//h/8AA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_68', '26_full', 68, '26_full_68');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_69', 1, 26, 14, '///////4AOADgA4AOADgA4AOAD/+//v/7gA4AOADgA4AOADgA4AOAD//////8A==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_69', '26_full', 69, '26_full_69');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_70', 1, 26, 13, '///////ADgBwA4AcAOAHADgB/+//f/uAHADgBwA4AcAOAHADgBwA4AcAAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_70', '26_full', 70, '26_full_70');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_71', 1, 26, 19, 'APAAf8A//A+HweA4eAOOAHOADnAADgABwABwAA4B/8A/+Af7gAdwAO4AHcADvADzgB44B8fD+H/z
B/xgPgw=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_71', '26_full', 71, '26_full_71');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_72', 1, 26, 15, '4A/AH4A/AH4A/AH4A/AH4A/AH4A////////4A/AH4A/AH4A/AH4A/AH4A/AH4A/AHA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_72', '26_full', 72, '26_full_72');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_73', 1, 26, 3, '/////////////A==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_73', '26_full', 73, '26_full_73');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_74', 1, 26, 12, 'AHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHwHwHwHwH4O8ef8f8Hw');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_74', '26_full', 74, '26_full_74');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_75', 1, 26, 17, '4AfwB7gHnAOOA8cDw4PBw8DjwHHAOeAd8A/8B+4D54HhwODwcDw4DhwHjgHHAPOAPcAe4AfwAcA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_75', '26_full', 75, '26_full_75');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_76', 1, 26, 12, '4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A//////');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_76', '26_full', 76, '26_full_76');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_77', 1, 26, 21, '8AD/wAf+AD/wA//AH/4A37AG/YB37gO/cBn5gM/MDn5wY/ODH4w4/HHH44w/DGH4Zw/DuH4dg/Bs
H4Pg/B4H4HA/A4HA');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_77', '26_full', 77, '26_full_77');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_78', 1, 26, 17, '8AP4Af4A/wB/wD/gH7gP3AfnA/OB+OD8cH4cPw4fg4/B5+Bz8B34DvwD/gH/AH+AP8AP4AfwAcA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_78', '26_full', 78, '26_full_78');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_79', 1, 26, 20, 'AfgAf+AP/wHw+BwDw4AceAHnAA5wAOcAB+AAfgAH4AB+AAfgAH4AB/AAdwAOcADngA48AcPgPB8P
gP/wB/4AH4A=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_79', '26_full', 79, '26_full_79');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_80', 1, 26, 14, '/+P/z/+4D+AfgH4B+AfgH4B+AfgP//v/z/44AOADgA4AOADgA4AOADgA4AOAAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_80', '26_full', 80, '26_full_80');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_81', 1, 26, 20, 'AfgAf+AP/wHw+BwHw4AceAHnAA5wAOcAB+AAfgAH4AB+AAfgAH4AB/AAdwAOcADngZ48H8Pg/B8P
gP/8B//gH48=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_81', '26_full', 81, '26_full_81');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_82', 1, 26, 16, '//j//P/+4A/gB+AH4AfgB+AH4AfgB+AO//z//P/44DjgHOAO4AfgB+AH4AfgB+AH4AfgBw==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_82', '26_full', 82, '26_full_82');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_83', 1, 26, 17, 'A/AH/gf/h4PjgHOAOcAO4AdwADwAD4AH/AH/wB/wAPwADwAD8AH4AGwANwA7wBzwPD/+D/wB+AA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_83', '26_full', 83, '26_full_83');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_84', 1, 26, 15, '///////4HAA4AHAA4AHAA4AHAA4AHAA4AHAA4AHAA4AHAA4AHAA4AHAA4AHAA4AHAA==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_84', '26_full', 84, '26_full_84');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_85', 1, 26, 16, '4AfgB+AH4AfgB+AH4AfgB+AH4AfgB+AH4AfgB+AH4AfgB+AH8AdwB3AOeB4+PB/8D/AD4A==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_85', '26_full', 85, '26_full_85');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_86', 1, 26, 17, '4APwAfgA7gB3AHOAOeAccA44DhwHBwODgcHBwHDgOHAcOA44A5wBzgDnADcAH4APwAPAAeAA8AA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_86', '26_full', 86, '26_full_86');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_87', 1, 26, 24, 'wDwDwDwDwDwDwDwD4H4H4H4HYGYGYGYGYOcGYOcGcOcOcMMOMMMMMcOMMcOMMYGMOYGcO4HcG4HY
GwDYGwDYHwD4HwD4HwD4DgBwDgBw');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_87', '26_full', 87, '26_full_87');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_88', 1, 26, 18, '8APcAOeAcPAcHA4Hh4DhwDzwBzgB/AA/AA+AAeAAeAA/AA/ABzgDzgDhwHh4HA4PA8OAccAe8AO4
APA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_88', '26_full', 88, '26_full_88');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_89', 1, 26, 17, 'wAHwAfgA7gDnAHHAcOA4ODgcHAccA44A7gB/AB8AD4ADgAHAAOAAcAA4ABwADgAHAAOAAcAA4AA=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_89', '26_full', 89, '26_full_89');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_90', 1, 26, 16, 'f/9//3//AA8ADgAeABwAOAB4AHAA4AHgAcADwAeABwAPAB4AHAA8AHgAcADwAP///////w==');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_90', '26_full', 90, '26_full_90');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_91', 1, 26, 7, '////Dhw4cOHDhw4cOHDhw4cOHDh///w=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_91', '26_full', 91, '26_full_91');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_92', 1, 26, 9, 'wGAwDAYDAMBgMBgGAwGAYDAYBgMBgMAwGAwDAYDA');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_92', '26_full', 92, '26_full_92');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_93', 1, 26, 7, '///4cOHDhw4cOHDhw4cOHDhw4cP///w=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_93', '26_full', 93, '26_full_93');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_94', 1, 26, 9, 'CA4Pju4+DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_94', '26_full', 94, '26_full_94');
INSERT INTO iris.graphic (name, color_scheme, height, width, pixels)
    VALUES ('26_full_95', 1, 26, 8, 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//8=');
INSERT INTO iris.glyph (name, font, code_point, graphic)
    VALUES ('26_full_95', '26_full', 95, '26_full_95');

COMMIT;
