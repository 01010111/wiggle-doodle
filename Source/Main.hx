package;

import haxe.Json;
import WiggleShape.PersonaShapeOptions;
import zero.utilities.Timer;
import openfl.events.MouseEvent;
import openfl.events.Event;
import openfl.display.Sprite;

@:expose
class Main extends Sprite
{

	public static var i:Main;
	public static var line_thickness:Int = 4;
	public static var fill:Bool = false;
	public static var palette_index_line:Int = 1;
	public static var palette_index_fill:Int = 8;
	public static var palette = [
		Color.PICO_8_BLACK,
		Color.PICO_8_DARK_BLUE,
		Color.PICO_8_DARK_PURPLE,
		Color.PICO_8_DARK_GREEN,
		Color.PICO_8_BROWN,
		Color.PICO_8_DARK_GREY,
		Color.PICO_8_LIGHT_GREY,
		Color.PICO_8_WHITE,
		Color.PICO_8_RED,
		Color.PICO_8_ORANGE,
		Color.PICO_8_YELLOW,
		Color.PICO_8_GREEN,
		Color.PICO_8_BLUE,
		Color.PICO_8_INDIGO,
		Color.PICO_8_PINK,
		Color.PICO_8_PEACH
	];

	static var distance_threshold = 8;

	var can_draw:Bool = true;
	var shapes:Array<WiggleShape> = [];
	var cur_shape:Array<Vec2>;
	var canvas:Sprite;
	var cur_line:Sprite;
	var drawing:Bool = false;

	public function new()
	{
		super();
		i = this;
		addChild(canvas = new Sprite());
		canvas.fill_rect(Color.WHITE, 0, 0, 10000, 10000);
		addChild(cur_line = new Sprite());
		addChild(new Toolbar({
			fill: () -> change_fill(),
			fill_color: palette_index_fill,
			line_color: palette_index_line,
			change_line: (i) -> change_line(i),
			erase: () -> undo(),
			simplify: () -> reduce_last(),
			simplify_all: () -> reduce_all(),
			clear: clear,
			select_line_color: (i) -> return palette_index_line = i,
			select_fill_color: (i) -> return palette_index_fill = i,
		}));
		addChild(new Palette());
		canvas.addEventListener(MouseEvent.MOUSE_DOWN, pointer_down);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, pointer_move);
		stage.addEventListener(MouseEvent.MOUSE_UP, pointer_up);
		stage.addEventListener(Event.ENTER_FRAME, util.UpdateManager.update);
		update.listen('update');
	}

	function reduce_last() {
		if (shapes.last() != null) reduce_poly(shapes.last().options.poly);
	}

	function reduce_all() {
		for (shape in shapes) reduce_poly(shape.options.poly);
	}

	function clear() {
		output();
		while (shapes.length > 0) shapes.pop().remove();
	}

	function undo() {
		shapes.pop().remove();
	}

	function change_fill():Bool {
		fill = !fill;
		return fill;
	}

	function change_line(n:Int):Int {
		trace(n);
		line_thickness += n;
		return line_thickness;
	}

	function play_animation() {
		can_draw = false;
		var i = 0;
		for (shape in shapes) shape.alpha = 0;
		for (shape in shapes) Tween.get(shape).prop({ alpha : 1 }).duration(0.1).delay(i++ * 0.05 + 1).on_complete(() -> if (shape == shapes.last()) can_draw = true);
	}

	function get_color(n:Int) {
		if (fill) palette_index_fill = (palette_index_fill + n).min(15).max(0).to_int();
		else palette_index_line = (palette_index_line + n).min(15).max(0).to_int();
	}

	function pointer_down(e:MouseEvent) {
		if (!can_draw) return;
		cur_shape = [[e.localX, e.localY]];
		drawing = true;
	}
	
	function pointer_up(e:MouseEvent) {
		if (!drawing) return;
		cur_shape.push([e.localX, e.localY]);
		remove_near_vectors(cur_shape);
		add_shape({
			poly: cur_shape,
			line_thickness: line_thickness,
			line_color: fill ? null : palette[palette_index_line],
			fill_color: fill ? palette[palette_index_fill] : null,
			wiggle: 1,
			jiggle: 0,
			speed: 400
		});
		cur_line.graphics.clear();
		drawing = false;
	}

	function add_shape(options:PersonaShapeOptions) {
		var shape = new WiggleShape(options);
		shapes.push(shape);
		canvas.addChild(shape);
	}

	function remove_near_vectors(a:Array<Vec2>) {
		for (i in 1...a.length - 1) {
			if (a[i].distance(a[i - 1]) < distance_threshold && a[i].distance(a[i + 1]) < distance_threshold) {
				a.remove(a[i]);
				remove_near_vectors(a);
				break;
			}
		}
	}
	
	function pointer_move(e:MouseEvent) {
		if (!drawing || !can_draw) return;
		cur_shape.push([e.localX, e.localY]);
		cur_line.graphics.clear();
		var a = [for (v in cur_shape) v.copy()];
		if (fill) {
			var c:Color = cast palette[palette_index_fill].copy();
			c.alpha = 0.25;
			var aa = [for (v in a) v.copy()];
			cur_line.fill_poly(c, aa);
		}
		cur_line.poly(fill ? palette[palette_index_fill] : palette[palette_index_line], a, line_thickness);
	}

	function update(?dt:Float) {
		for (shape in shapes) shape.update(dt);
		Timer.update(dt);
		Tween.update(dt);
	}

	function reduce_poly(poly:Array<Vec2>) {
		for (i in 1...poly.length - 1) if (i % 2 == 0) poly.remove(poly[i]);
	}

	public static function input(input:String) {
		Main.i.clear();
		var shapes:Array<PersonaShapeOptions> = Json.parse(input);
		for (shape in shapes) Main.i.add_shape(shape);
	}

	public static function output() {
		trace(Json.stringify([for (shape in Main.i.shapes) shape.options]));
	}
	
}