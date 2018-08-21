var RESOURCES = {
	"visible_buttons" : "save,undo,redo, ,resize,canvas_size, ,crop,cropmode, ,rotate,cclockw,clockw, ,fliph,flipv, ,color,eyedropper,vars,curves,sepia,grayscale, ,zoom",

	"text.ok" : "OK",
	"text.cancel" : "Cancel",
	"text.yes" : "Yes",
	"text.no" : "No",
	"text.message" : "Message",
	"text.warning" : "Warning",
	"text.error" : "Error",

	"text.loading" : "Loading the image ... ",
	"text.processing" : "please wait ...",

	"text.height" : "height",
	"text.width"  : "width",
	"text.size" : "Size",

	"text.color" : "Background Color",
	"text.eyedropper" : "Pick color in the image",
	"text.resize" : "Image size",
	"text.rescale" : "Rescale image",
	"text.constrain_proportions" : "Constrain proportion",
	"text.canvas_size" : "Canvas Size",
	"text.anchor" : "Anchor",
	"text.crop" : "Crop",
	"text.cropmode" : "Crop Mode",
	"text.angle" : "Angle (in degrees)",
	"text.rotate" : "Rotate",
	"text.clockw" : "Rotate clockwise",
	"text.cclockw" : "Rotate counter-clockwise",
	"text.flipv" : "Flip vertical",
	"text.fliph" : "Flip horizontal",
	"text.vars" : "Adjust brightness, contrast",
	"text.curves" : "Curves",
	"text.grayscale" : "Gray Scale",
	"text.sepia" : "Sepia",
	"text.redeye" : "Remove Red Eyes",
	//"text.select" : "Select area to crop",
	"text.constraint.maxsize" : "Image exceeds maximum size ",
	"text.constraint.minsize" : "Image size is too small",
	"text.color_by_pixel" : "Pick a pixel in the image to set current background color",

	"text.transparent" : "Transparent",
	"text.rgb"   : "RGB Color",
	"text.red"   : "Red",
	"text.green" : "Green",
	"text.blue"  : "Blue",
	"text.hex" : "Hex",
	"text.hue" : "Hue",
	"text.saturation" : "Saturation",
	"text.brightness" : "Brightness",
	"text.contrast"   : "Contrast",
	"text.color_tempr": "Color Temperature",

	"text.cropshape" : "Shape",
	"text.rectangle" : "Rectangle",
	"text.ellipse" : "Ellipse",
	"text.feather" : "Feather",

	"text.undo" : "Undo previous action",
	"text.redo" : "Redo the action that was undone",

	"text.saving" : "Saving the image...",

	"text.zoom" : "Zoom",
	"text.fitwin" : "Fit in Window",
	"text.save" : "Save image",

	"text.density" : "density",
	"text.dpi72"  : "Web 72 dpi",
	"text.dpi150" : "Print 150 dpi",
	"text.dpi300" : "Press 300 dpi",
	"text.units" : "units",
	"text.pixels" : "pixels",
	"text.inch" : "inch",
	"text.cm" : "cm",

	"icons" : {
	"canvas_size":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAASxQTFRFAAAA/f39+Pj4+/v7+/v7/f39////k7LTscng/v7+8/PzWYy+jK7R////KWiqK2urWYm8ImSnH2OlIGOmH2OlHmGmcpzG/v7+7PD36O/1///+dZ7JXYy+d6DIlLPTIGOnM3CuHmGlI2WnMG6szNrqMm+tJmepK2qqM3CuMW+tpcDaMG6tMm+tM3CtKGipZmZmaWlp7e3t4uLiqampmpqa3d3d5+fnmZmZ3NzcnZ2d9/n7/////v7+///+JWepHGGlZZTCy9npR362NHGvNXGvK2qrMW+t3t7e//7/6u/16O/16vD1l7XVGV2kpL/a0N7rjq/SImSnq8TdsMngH2GmM3CvtMziIWOnKWipImSoM3CuKGipJ2ipNnKwQnq0P3iyNnKvJ2epJWapJmap+9M0wgAAAC90Uk5TAGolaqj+/v7+/m79/f39/f3+/f3+/f39/f39/f79/f79/f3+/f3+/v79/f3+/f5YXsMVAAAAAWJLR0QAiAUdSAAAAAlwSFlzAAAOxAAADsQBlSsOGwAAAQZJREFUKM9jYCAD6BsYMBoYGDABMTMQswCxPkTG0NDIGBVDxA0wxI0MIBJGJqZmpuYWZhbmRoZGlkBsApUwNjJjZbNi57BmY7NhZeUEqoNIcAH1Wtty29nzODjyWluzAtVxwewwsXbic3bhd3UDSSDZYenOJiAoJCwiKsbGK26DYoe1h4Snl6S3tZSPNSdQHZId1kBDpKytpX392FDs4OSVkeXl5JWTV1D0R7HDOkApMIg3OETBOVQZxY6wcIXQCJXIKFVnFzUUO9RVNVQ11bW0dVQVolHsiIlViIrSjIvXdUnQQ7EjMFEvMVEvKRlICiLZ4Y4atnA70MRR7EAOd7gduKOWNAAAymZK1AEfJvkAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTUtMDUtMDVUMDk6MjY6MjgtMDQ6MDCPNQadAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE1LTA1LTA5VDE4OjE0OjE2LTA0OjAwWnSfmAAAAABJRU5ErkJggg=="
,	"cclockw":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAJlQTFRFAAAAAESVCFGcAEaUAEaUgT+iGl6jAESUgj+jAEaVCFOcAEGHGmGjGmGjGl6jAEaXgT+iHWGmAEaXhkOpCFOcAEaVCFGcAEaXgT+iClOfAEaUhYWFgoKChUGmi4uLgT+ijY2Ni4uLg0Cli4uLgT+ijIyMi4uLgkCki4uLjIyMi4uLgT+iHWGmgT+iHGGngD6igDyii4uLgDyjU+wYEwAAACx0Uk5TABdNNGb4CGZ8Brwl/GMHaJadaw15Elc9so8kBmYgZs8Q1jx45R3mV40p8mi/1d1FAAAAAWJLR0QAiAUdSAAAAAlwSFlzAAAOxAAADsQBlSsOGwAAAJRJREFUKM/N0MkOwjAMBFCz71D2fSs7eIDh/z+OpCqQtOLGAR+SaJ4sWxH558pkc19ENW/OQhqKqiURlP20UlVT15oAPtS10VRtmQ4Ebt5WO6MjFtB1B/ekPxja1w0YOTCeRNd0JnfTMk/utSDlYWDpx6s1Y0Do5hvyDdtPvNvTARxe+ZH0IP6Y05kJwCUCMgWQX9YTSUsY5o6wHQIAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTUtMDUtMDVUMDk6MjY6MjgtMDQ6MDCPNQadAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE1LTA1LTA5VDE4OjE0OjE2LTA0OjAwWnSfmAAAAABJRU5ErkJggg=="
,	"clockw":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAJlQTFRFAAAAAEaUCFGcAESVgT+iAEaUgj+jAESUGl6jAEGHCFOcAEaVgT+iAEaXGl6jGmGjGmGjhkOpAEaXHWGmgT+iAEaXCFGcAEaVCFOchUGmgoKChYWFAEaUClOfgT+ii4uLg0Cli4uLjY2NgT+ii4uLgkCki4uLjIyMi4uLgT+ii4uLjIyMHWGmgT+iHGGngD6igDyigDyji4uLj4LKoAAAACx0Uk5TADRNF/hmfGYIJbwGlmgHY/wNa52yPVcSeSBmBiSPz2Y81hDleFfmHY1o8ils2Ig6AAAAAWJLR0QAiAUdSAAAAAlwSFlzAAAOxAAADsQBlSsOGwAAAJNJREFUKM/V0UcOAjEMBVDTOwy9t6GDTfn3PxwOipiULRssRVH+UxTLIfqDyuULUVbUVWKO8rIQVZirEYhQ7c5a9YaXNxWoxdzucOLmXTFAPfMG9x0YiDzMPhyNaeI0MNULT5rNP4fFMoOVwouAddDRRixgm3qw+wKwd/KDOIDjKRuGB8DZ5hcJANebHUYIwE+/7A1rlRkKUwd8zQAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNS0wNS0wNVQwOToyNjoyOC0wNDowMI81Bp0AAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTUtMDUtMDlUMTg6MTQ6MTYtMDQ6MDBadJ+YAAAAAElFTkSuQmCC"
,	"color":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAJ9QTFRFAAAAVVVVT09PVVVVZGRkmZmZUFBQV1dXlpaWmZmZYmJiTExMi4uLlJSVHWawImmxeHh4d3d3TXaeHmKngICATExMUFBQgYGBHmKnmZmZXl5elZWVHmKnSUlJlpaWlZWVkpKSHmOoHmKnH2SrHmKnTk5OTExMlpaWmZmZSEhIFl6oHmKnl5eXmZeXRHKgTU1NGl+nHGGlHWGnmZeVHmOoJcPmUAAAACV0Uk5TAEyeFilhpmZV/j/CeE88JxQZ484q3FwTevsmw+Dr5LqR5e5ljZCsccAAAAABYktHRACIBR1IAAAACXBIWXMAAABIAAAASABGyWs+AAAAkklEQVQoz7XRxw7CMBBF0UfvvddQ8xLbhBD4/28jgEDyyNmAmIU1Olfe2MD3k8tnhMIx64pfLDmd5QqrLq/VG0220O4IZ9ANewH7Sg9spxmOxpMTI6WnlnMG/zxfkFG8tJwGqxDrdLkkdqAHbMgrlYYoxjxOxBqyPB2JhqOk680K+LgMeDu2O/koL8f+8MPn/XnuHJITl/qZ5ScAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTUtMDUtMDlUMTg6NDQ6MDYtMDQ6MDCW1Iv4AAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE1LTA1LTA5VDE4OjE0OjE2LTA0OjAwWnSfmAAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAAASUVORK5CYII="
,	"crop":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAQAAABKfvVzAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAJiS0dEAACqjSMyAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAsklEQVQ4y7WSsQ7DIAxEn0k+srQkG3wUjKGlH9mKDkiNlBDCkpss644728DVkLV0GcBLjWaVRG5egep51Q4S0byhS2BHWdCkbP6RSpgmUp7Ct9MBIM+F3i0In44t2UEWdKnX7qGDU2XUbf84UkST8rRtjwfvRzQJI7v9VRycci8ePP09Z38ucEMJ442VULnP3qGMalyVXhNoEjOVMAW7O7TgpfvSzS21IWeE7Ye5PtL1+AFo9zeSWQ4UmwAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNS0wNS0wNVQwOToyNjozMC0wNDowMHBwSGQAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTUtMDUtMDlUMTg6MTQ6MTYtMDQ6MDBadJ+YAAAAAElFTkSuQmCC"
,	"cropmode":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAE5QTFRFAAAAN3KvN3KvN3KvN3KvN3KvN3KvN3KvN3KvN3KvN3KvN3KvN3KvN3KvN3KvN3KvN3KvN3KvN3KvN3OwN3OwN3OwN3OwN3KvMzMzN3OwFv35/gAAABd0Uk5TACHA/dJRhP7Ci68s3Zzy9/z6zfL29fSEafCaAAAAAWJLR0QAiAUdSAAAAAlwSFlzAAAASAAAAEgARslrPgAAAG9JREFUKM+lztcOgCAMQFHcAxEcWPj/HzUKkTKMJN4n6EkKhPyoKCsAqJtw3nZg6v35AE8jntPJAVAEbEbA4g8Y4N7tyh6FhSUE/gZrGtyLISgVw10KlO0DBAa8atP7LuUhtQ4A9QLKfyID0utzOwHROhUIwnYYgQAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNS0wNS0wNVQwOToyNjozMC0wNDowMHBwSGQAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTUtMDUtMDlUMTg6MTQ6MTYtMDQ6MDBadJ+YAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAABJRU5ErkJggg=="
,	"curves":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAATJQTFRFAAAA77JS77JS/r5Z8bRT77JS77JS8bRT8rRT56xO56xO9rdU56xO7rFR6K1O56xO56xO6K1O7rJR56xO6K1OTU1NXV1d56xO56xOPz8/X19fYGBg77JSTk5OYGBgYGBgX19fUFBQ6K1O6K1OYGBgYGBgQkJC669R669R56xO56xOa2NXamZf8bRT8bRT56xO56xOY2JgpIdY6a1Q6a5QYGBgQkJC7rJSYGBg56xO56xOXVI/YGBg56xO8bRT6a5Q56xO56xO6a5Q56xOYGBg8bRT6K1O6a5Qe29cbWde/8Fa9rdU77JS77JSQ0NDYGBgTk5O77JS77JSRkZGYGBgYGBgOjo6QkJCVFRUX19fYGBgSkpKYGBgYGBgQUFBYGBgYGBgXV1dTk5O56xOYGBgupBOh/aYqwAAAGN0Uk5TAMqRAjzWm1FXSoQpbxyj29aRBBI8LIZdLgKP8icS5/arXLeA3L8EvMX3vmH4pKz1vMnOsnvtCB/7USIP5YgRls7JhBrJZjoBzKEBMtiZBPQjzI8GzcwCF1Ck6Q75ogTAwplKbtmHTwAAAAFiS0dEAIgFHUgAAAAJcEhZcwAAAEgAAABIAEbJaz4AAADaSURBVCjPY2CgAWBkwhBiZgGRrGwgkh1ZgiOZE8bkSuZGluFJZuDl4xcQFBJOFgHxRcXgUuLJYCABZEpKSaekwMRlkqGAgUFWLkVeQREmoQSTUGZQSVFVg4qqazBowiS0tFN04Obr6jHowyQMDFOMkJ1lDJMwMU0xQ5Ywh1tuIY/qeUuIuJV1ig2ysG0yg529g6MTg3NqiguSuGuyG5B0BzE9UjyRJLy8QaSPLwODn39KAEYYBwYxBIekhGKIh4VHRMqnREVjSFikpKTExMZhRmB8QmISORGPAABbtzOV3/cNgwAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNS0wNS0wNVQwOToyNjozMC0wNDowMHBwSGQAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTUtMDUtMDlUMTg6MTQ6MTctMDQ6MDD8A5QsAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAABJRU5ErkJggg=="
,	"eyedropper":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAMxQTFRFAAAAREREREREikesh0Wnh0Wnh0WnREREREREhUSlhESkREREREREikesiUerhESkREREREREhUSmREREREREh0OshESkREREhUSlREREREREam5qhESkhkWmbW1thESkTExMbW1thUSlbW1tbG1siUepikesjkmwbW1tbW1tbW1tbW1tb29vbW1tbW1tbW1tbW1tbW1tbm5ubm5udXV1bW1tbW1tdHR0bW1tREREhESkhEOlhEGmhECnbW1sa25phEGnbW1ta29og0KlZMCLzQAAADl0Uk5TAHV7BYq4dfwxL6N4h0FgKS4aGn6NB7EbA4mPwPcPzIcDwMup7CCMDYTmTt4W8KejcUgvEw39hUtVRgPDeQAAAAFiS0dEAIgFHUgAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAC3SURBVCjPrZHVEgIxDEWDu7st7u6kaOH//4l0u2Vgt7ww3Ic0czo3aVKAH4VfuAvdr9zj9flVHsAgKk+IkcIyjwiIUQqxeIKZkvUxST1S5EkzJenImI4sQO5o8bx6ExasHid5UVTdS1g2zwqcCVdr9jmMyxVujNXfBmmI0OSc3+HBWrYp28R5B7q9/icfCD50bmUk+NjJJ4IbmjVOic80fE58oeFL4isNX+vLw2bLd9r/2/MD/EFPcS4dnyso2IwAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTUtMDUtMDVUMDk6MjY6MzAtMDQ6MDBwcEhkAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE1LTA1LTA5VDE4OjE0OjE3LTA0OjAw/AOULAAAAABJRU5ErkJggg=="
,	"fliph":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAHJQTFRFAAAAoaGhmFi5m5ubkFOukFOulpaWjVKrm5ubkFOulpaWjVKrmpqakFOulpaWjVKrmZmZkFOulpaWjVKrmZmZj1OulpaWjVKrmZmZj1OtlpaWjVKrmJiYj1OtlpaWjVKrl5eXjlKsl5eXlpaWjVKrjlKsXa7tAQAAACJ0Uk5TABUIE/cgtb8aHby8IB7FvSwf0MAzItfCQCTjxkco6coxDyekH2gAAAABYktHRACIBR1IAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAeklEQVQoz73RRxaCUBBE0ZYoiCiCgSDo73b/WxRO/whMoYbvDgtg1x0AvLXuC4AgXIEIAShe9iNOQMkCUobTvGfIQOcZ5Aoubr+iAiocuBko7V6hAbpb8LDhafoLbaBaQ+NCq3qHCn4sbwk9d6Fh4P4RciPIfTf9V+8P8S0TzjDjgd4AAAAldEVYdGRhdGU6Y3JlYXRlADIwMTUtMDUtMDVUMDk6MjY6MzAtMDQ6MDBwcEhkAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE1LTA1LTA5VDE4OjE0OjE3LTA0OjAw/AOULAAAAABJRU5ErkJggg=="
,	"flipv":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAHJQTFRFAAAAl5eXmJiYlpaWmZmZlpaWmZmZlpaWmZmZlpaWmpqalpaWm5ublpaWm5ublpaWoaGhmFi5kFOukFOujVKrkFOujVKrkFOujVKrkFOujVKrj1OujVKrj1OtjVKrj1OtjVKrjlKsl5eXlpaWjVKrjlKsOgkiCQAAACJ0Uk5TADFH6UDjM9cs0CDFGrwTtRUI9yC/HbwevR/AIsIkxijKD8ZFAQEAAAABYktHRACIBR1IAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAcElEQVQoz63Q2Q6CUBAD0Aoqi4KyurGX+/+/6COYdBJi6GNPmkwG2CEHXXv+pOrjiRRwDkgBYUQKiC+kgGtCCkhvpIL79NPLczcmy+clzrlFinJe03pU1QYAj6cBwOttAPBpDADazgCgHwwAxj/f8QVLDhPOZtB40wAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNS0wNS0wNVQwOToyNjoyOC0wNDowMI81Bp0AAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTUtMDUtMDlUMTg6MTQ6MTctMDQ6MDD8A5QsAAAAAElFTkSuQmCC"
,	"grayscale":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAQAAABKfvVzAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAJiS0dEAACqjSMyAAAACXBIWXMAAA7EAAAOxAGVKw4bAAABIUlEQVQ4y7XTwStEURTH8c+b0UzoKXb+Ahv8Af4N/gLWsrJBFigLC2rK0tLKlFKsZCELpVhZWBALjUKKRppmnoXpefHezJT87ub87j3fzunec/lvBTCz8zrePrWvvDHRDCejRsZKajKCHKh/lQpE7t2qNd0P1aEruRM58yRwZ8y7gkJKYwmg4dYzqDpRlTNq8BeQ+w4vXcXxOyI3KRUSQPXXYbF1S8OuvWnEPjSUDQToNZKSsGIhq6U0bclbagUcOki4PRUFRZtZQMWxU49Nd+5CEV1e7KcDJaHQOniyqye+raM0YFE/GDCP7Tg94x1mhfH09Fs2rS5qBSSHLdCtZE6tNZBU4MNqu+F70Im+gDxr7XPzMRCWpzr4omG5oxb+rE9tPWDH4gAObQAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNS0wNS0wNVQwOToyNjoyOC0wNDowMI81Bp0AAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTUtMDUtMDlUMTg6MTQ6MTctMDQ6MDD8A5QsAAAAAElFTkSuQmCC"
,	"redeye":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAc5QTFRFAAAA87pe8rle8rle8rle9Ltf7bRc6LFa6LFa6bJa6LFa6LFa7bRc6LFa6LFa7bRc6LFa6LFa6LFa6LFa6LFa6LFa6LFa6LFa6LFa6LFa6rNb6rNb7LNb6LFa6LFa8rle7bRc6bJa6bJa7LNb77dd9btf6LFa6bFZ7bJW6bdc6rNa6LFZ57BY77FS4bBeqaOH0mk40l8y1GMwx4FL469Z7rJV565U77ZcoqumRozOoFJVyjcbxjYc02hV//P0ibHZrJ998LFP5q1Q7cKA////a5nKUJHIzzUVyD0hxTQY6rux1OTzQ4LCycCr6a1M5qxP8MuTb5vHUJHJzTgZxzsgykct7auckHyOTYe+0+T59tms5qxO565S78qOmbjXUIzEm15izzcWyTsfyjkbyjAOXYi4TIO6/P397caG561S6rlt8fX5TYK5UpHIk2Jtu0UzrlBGaIOrUIm/lLTU7L95569W569U6rpv9+rVztvqUIzCUZDIUY/HToa9d5/J+u/c6bNg5qtO6bho9N65/f388/r/oL7ffKXPh63Txdjs+/Tq7caI5qpL57BW561R6rxz89Sf/eW//+7R/+/U++TC8tSj6bps5qtM565T5qxQe1MoNwAAACZ0Uk5TAENmZ00TNMbrZa3gBOb7Bee4kkUX4r3y0DRgNHz+q0Sf5vW/cQlfpqNeAAAAAWJLR0QAiAUdSAAAAAlwSFlzAAAOxAAADsQBlSsOGwAAAPtJREFUKM9jYKArYGRiZmHFEGVjVwMDDk5UcS41NXUNTU1NLW01bh4kcV41HV09fQNDI2MTUzU+fri4gJqZuYWllbWNrZ29g6OaAExcUM3J2cXVzd3D08vF28fXT00IIi6s5h/g4hIYFOwREhoWHhEZFa0mApYQjYl1cXGJi09ITEpOSU1Ld8nIFANL6GQBxV2yc3Lz8gsKi4qB7JJSsIR4WXkFkFeZU1VdU1sHZNU36EAskShtbGpucWlta+/odHHp6u7RkYQ6S0qtt6+nf8LESZOnTJ02vUxNGuFDGVm10hl9TjP7ZpSqyaEGiryCIjColJRVVOkbdaQBAA5NPX1tVhZKAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDE1LTA1LTA1VDA5OjI2OjI4LTA0OjAwjzUGnQAAACV0RVh0ZGF0ZTptb2RpZnkAMjAxNS0wNS0wOVQxODoxNDoxNy0wNDowMPwDlCwAAAAASUVORK5CYII="
,	"redo":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAK5QTFRFAAAANHGvNHCvNHKvNHKvM3CtM3KtM3CtNXKwNXKwNXKwNXKwM3CtNXKwNXOyNXKwNXKwM3KtNHCvNXKwNHKvNXKwNHKvNXKwNHKvNXKwNHKvNHCvNXKwNHKvNHKvNHCvNXKwNHKvNXKwNXKwM3KtNXKwNHKwNnSyNXKwNXKwM3KtNHKvNHCvM3CtNHCvNHGvM3CtNHGvNHCvNHKvNHKvM3CtNHCvM3KtNXKwNHGv/rZBtgAAADR0Uk5TAFbMx2bWUFnmlUdx/HpXi/ydPtjznJz6hniT/PGZ0fvWz3mqaXIwMvjl2P3+LP2CQP7iPspwD0oAAAABYktHRACIBR1IAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAp0lEQVQoz9WRVw7CMBBETQ+9994JhNDGXuf+F2O9VvjhAIj58cw8r7WSlfpDZbIAcvmvvqANiYoSS2kfWKutV9llW/F9la/W6o1my5E2F0QdAV1CT0yfAQ2UAozkIWHkZ8cMMGEwlTgjzFVKCFgAS0krwjrdY8MAKdhy+Gy+E+Cf2jM48Hk8BWF4vjgQCbia2NycuWutTRSzHn5cJ8lTzIsse6cff9EbNYAbGs497s0AAAAldEVYdGRhdGU6Y3JlYXRlADIwMTUtMDUtMDVUMDk6MjY6MjgtMDQ6MDCPNQadAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE1LTA1LTA5VDE4OjE0OjE3LTA0OjAw/AOULAAAAABJRU5ErkJggg=="
,	"resize":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAANVQTFRFAAAAO3WucHBw/f39cHBwcHBwGRkZPHaxLFaBcHBw+Pj4/////f395+/1k7LT5uz0/v7+/f38/Pz9NHCuMm6sPXaxhKfMfqTL//7+JGaoOHOvO3SwOXSvJmaowdPld5/IRXy0RX2zQ3u0QnuzYI6+/P79///+Voi72eTwrMTdeqLJMG2sOHOu/v79ytnpI2WmapbDmbfVL2yrN3KvXo6+6/H2L22rO3WvLmuqn7vYwNHkK2qqPHWwSH61OXSwLWurmrnXOnSvOnSwO3WwN3Ovb5nE+fn537zodgAAAAZ0Uk5TAHDz/fT2mrXNBAAAAAFiS0dEAIgFHUgAAAAJcEhZcwAADsQAAA7EAZUrDhsAAADLSURBVCjPnZHXEoIwEEXBtolrQbH3XrGX2Lv8/ycZBoRge/AMw8OevTcZkKR/CATenq+rwtsEOIS4tK0IF5+qZELAEh5qY8xlAGuHBvGJMedtVoJiCMORKKIS80qyJAqMq4lkKp1B9IrHcZHN5QtqsYQ8S52LclGuVGv1RjPTUl6ESavdQVPYVdg1RK+vDV4Sw9EYcTKF2dwtFku2Wm+2bLfT3FX7A7Dj6cwAmDtx4ZPr7a69Cf6tGVxzTsKq0tFBFxI+KuL/+Wt/8QATsxNLM48WBQAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNS0wNS0wNVQwOToyNjoyOC0wNDowMI81Bp0AAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTUtMDUtMDlUMTg6MTQ6MTctMDQ6MDD8A5QsAAAAAElFTkSuQmCC"
,	"rotate":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAARRQTFRFAAAAPXeyPXiyPXiyPXeyPXeyPXeyPXiyPXiyPXiyPXeyPXeyPXiyPXeyPXeyPXiyPXiyPXiyPXeyPXeyPnizPXeyPXeyPXiyPXeyPXeyPXeyPnizPXeyPXeyPXeyPXeyPnizPnizPnizPXeyPnizPXiyPXiyPXeyPXiyPXiyPXiyPXiyPXiyPXiyPXiyPXiyPnizPXiyPXiyPnizPXiyPXiyPXeyPnizPXiyPXeyPXiyPXeyPXeyPXeyPXeyPXeyPXeyPXeyPXeyPXiyPXiyPXiyPnizPXeyPXeyPXeyPXeyPXiyPXiyPnizPXeyPXeyPXeyPXiyPXeyPXeyPnizPnizPnizPnizPnizPnizPXeyPXiyi2B2agAAAFl0Uk5TAAFMUf4gv/7oCjTqYuky+pEX+h8Cvu4/Qe+8SftFR/yvoqat8jk78PcHCfjt8PkM7ERGpbO1ojz9XF86q/he+agU27IEBT+z2SHY8dT+1hGe/JwQLZPdkSxaJvz4AAAAAWJLR0QAiAUdSAAAAAlwSFlzAAAOxAAADsQBlSsOGwAAAPlJREFUKM+lktdaAjEQhQc9OOKK2LEg9t47drErYBdN5v3fwyUJm3Crc3Xm/EmmfCH6X6hGaK29k2prtwDQOiDpDu7MNIB24fyuCCLd7gayPcn5CMj19tka/UA0YP3BIWA43yw+MgqMpUw2DhQmkq6oOAkUTTal1LTvl2hGqVmTzAnP+0mIFlgWrZal5XDKlVWBA2ut868nYCMT+ps5B7aEt0Oww5I1YldkLwT7IgdGHJaEj7x/zFI6sfIUOEvI+QVw6XT5CuDr/A3R7d19vMWHcvPU41O8Xa5Uq5Va7D+n/bsvr29iQqHw/tEy1OdXPd5grf798+d/8QshoCzny/6fkQAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNS0wNS0wNVQwOToyNjoyOC0wNDowMI81Bp0AAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTUtMDUtMDlUMTg6MTQ6MTctMDQ6MDD8A5QsAAAAAElFTkSuQmCC"
,	"save":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAADZQTFRFAAAAjVKrjVKrjVKrjVKrjVKr3Mrl/v3+/////v7+3s7n/Pv9/fz9uLi4jVOr3s3njlSsklmuWOA8IwAAAAV0Uk5TAP3aFMyKBSHjAAAAAWJLR0QAiAUdSAAAAAlwSFlzAAAOxAAADsQBlSsOGwAAAFRJREFUKM+tz8kOgDAIRdE6IK8Orf3/n9WN5LUJrrjbEwKkFNokYwabwso7wQEqE5y4LKB8IC9wHYRNOFdJ94dWAufzH7hphQ5QWguA2YNlda4K6gGpUAnhesiPXgAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNS0wNS0wNVQwOToyNjoyOC0wNDowMI81Bp0AAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTUtMDUtMDlUMTg6MTQ6MTctMDQ6MDD8A5QsAAAAAElFTkSuQmCC"
,	"sepia":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAQVQTFRFAAAAb29vcHBwYmJiYmJi/////f799O/q2Ma2lnBJnHZTtZl89PDqmnNNrY5wrY9wpYRjuJyBon5c283AmHFLrY5vqYprro9xpIRjwquTy7SgnXpTpoVmpohlpoZlpoZmpohmqIhmnHZQ1MOz2Mi7wq2UwauVwayWwayTvqiP2sm7k2tB8uzoqolnqYlqmnVQtpyAvKKKtJp9poVkqotrpYNh08KvoH5bn3tV3dDExq6ZoYBdw62W6uHZmnRPro9wrI5vmnJL+PTy2Mq7nntWqIZl/v7+mXFMrI1vnXlTkWY+qopprI1tqotqqYpq+PPvnXlUq4xtpoVlvqaN1cSzqYlnqIVkvN/IAgAAAAR0Uk5TAKys/NVIj0wAAAABYktHRACIBR1IAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAv0lEQVQoz2NgIAMwsmAAJrAECysGYAFLMIPZbOxIEswICQ5OLm5sEjy8fPwCgrxC6BLCInyioqJi4hKSaBJS0jKycvIKikrK6EapqKqpa6hramFaDgfaOtgldPX0USUMDMHiRsZ8JqbIEmbmFpZAysoa6DoBG4SErZ29g6MTq7MLP9DVoq5wCTd3B1FRD09WL7C4qChcwtsHxPX18w/gQ5UIhCgMCg4xRpUQhYLQMFHsEjAAlcAZUViilpGcJAIAcDcZSbwWKmEAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTUtMDUtMDVUMDk6MjY6MjgtMDQ6MDCPNQadAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE1LTA1LTA5VDE4OjE0OjE3LTA0OjAw/AOULAAAAABJRU5ErkJggg=="
,	"undo":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAK5QTFRFAAAANHKvNHKvNHCvNHGvM3CtM3KtM3CtNXKwNXKwNXKwNHCvM3KtNXKwNXKwNXOyNXKwM3CtNXKwNHKvNXKwNHKvNXKwNHCvNHKvNXKwNHKvNXKwNHCvNHKvNHKvNXKwNXKwNHKvNXKwM3KtNXKwNHCvNHKvM3KtNXKwNXKwNnSyNHKwNXKwNHGvNHCvM3CtNHGvM3CtNHKvNHCvNHKvM3KtNHCvM3CtNXKwNHGvbHQsrQAAADR0Uk5TAGbHzFZZUNZHleY+nfyLV3r8cZyc89j8k3iG+vvRmfF5z9Zpqv792OX4MjBy/v1Agiw+4py7G4sAAAABYktHRACIBR1IAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAApklEQVQoz9WRVxLCMBBDTYfQe+8EQgtNa5v7X4z1BsMRGPSxI+nZO56xUv+rVBpAJvstcjLzJNKm4PuidbNkExlrg6QvE/GsuLJaqzeafKslQANKtYn7juQuqCemz2AABsNkwwg0FjMBpmDw7tUMNPeARQv/liVo5Vex1p/H86GNmND1210UBfsDxyODk4BzzAq1Mebi4lXH+ibgKTKW7hIf7H/9Ny8VMRrvmiYPGQAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxNS0wNS0wNVQwOToyNjoyOC0wNDowMI81Bp0AAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTUtMDUtMDlUMTg6MTQ6MTctMDQ6MDD8A5QsAAAAAElFTkSuQmCC"
,	"vars":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAASNQTFRFAAAAi4qJiomIhoWEiomIiomIiomIi4qJiomIi4qJiomIiIaFiIaFiomIi4qJi4qJiomIi4qJi4qJiIaFi4qJhIOCg4KBhYSDhYSEsbGw0NDR39/f6Ojo2dnZtbW0gH9+v76+////kI+PlpOTzc3Nw8LBg4KC5ebk/vz8//39e3l5ZWNjYmBgbWtr397e7+/ugX9+5OTkamdnbGpqXltbxcTE7e3su7q6dnR0a2lpXVtb4uLi/f39dHJycG9vrKyr09LSsLCvzMrLZmRkn56e2tna//7+cW9vaWZmiIaG2draiYaGysnJoJ+f0tDRq6qoYV9f1tbWrq2s/Pz8//z8dHFxhoWEtri1Xlxcu7m60NHR5ubmg4KAko+PysnK2drY4eHg8FPwswAAABV0Uk5TABuT5KLr6pycEonX1YMMkt2RD9QNPUKcIwAAAAFiS0dEAIgFHUgAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAEaSURBVCjPndJnV8IwFIDhMpVRKGIStdVw3RVUTF2IAxURF5sCguP//wrTpBxaP5KP73Oak9xUUeZdgWAIYYxCwYC/h8nK6ppurG8QEvb2CM0BX5tb27BDI7Me3d2DfdOEg3zh8OgYR6d9oXjidA7MYqdn58VF2WPkQnQTLpllla7KORITEEfXoptww8Fit4DiAhJ3YHrAKlTuEwLIgx8eqxUiAD3VXHgWUH8pIwmvNd8X9TcXyPu/rT4acqtk0w+tdicpQMXdnve4fcCqgJQ9cC/oQGlojOyUvHqa6nIkHNjwc0zT02FpEx16znHzrb4xnmiz8Wp00OVj/6q2YUQ9XVEyNm5+//w2OtjO+J9wSc0ShEhWXZ777/gDFSs5sYN14j0AAAAldEVYdGRhdGU6Y3JlYXRlADIwMTUtMDUtMDVUMDk6MjY6MjgtMDQ6MDCPNQadAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE1LTA1LTA5VDE4OjE0OjE3LTA0OjAw/AOULAAAAABJRU5ErkJggg=="
	}
}