class WiggleShape extends openfl.display.Sprite {

	static var freq_table = [0.13, 0.19, 0.15, 0.17];
	static var freq_index = 0;

	var counter:Float = 0;
	public var options:PersonaShapeOptions;
	public var last_poly:Array<Vec2> = [];

	public function new(options:PersonaShapeOptions) {
		super();
		this.options = options;
	}

	public function update(?dt:Float) {
		counter += options.speed * dt;
		
		// Wiggle
		var poly_copy = [];
		for (i in 0...options.poly.length) {
			var v = options.poly[i].copy();
			v.x += Math.sin(counter * freq_table[freq_index++ % freq_table.length] * i.rand()) * options.wiggle;
			v.y += Math.sin(counter * freq_table[freq_index++ % freq_table.length] * i.rand()) * options.wiggle;
			poly_copy.push(v);
		}
		for (v in last_poly) v.put();
		last_poly = [for (v in poly_copy) v.copy()];
		graphics.clear();
		if (options.fill_color != null) this.fill_poly(options.fill_color, poly_copy);
		if (options.line_color != null) this.poly(options.line_color, poly_copy, options.line_thickness == null ? 1 : options.line_thickness);
		
		// Jiggle
		scaleX += Math.sin(counter * 0.1) * options.jiggle * dt;
		scaleY += Math.cos(counter * 0.1) * options.jiggle * dt;
	}

}

typedef PersonaShapeOptions = {
	poly:Array<Vec2>,
	jiggle:Float,
	wiggle:Float,
	speed:Int,
	?fill_color:Color,
	?line_color:Color,
	?line_thickness:Float,
}