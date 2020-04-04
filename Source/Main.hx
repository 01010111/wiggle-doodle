package;

import WiggleShape.PersonaShapeOptions;
import js.html.BodyElement;
import zero.utilities.Timer;
import openfl.events.KeyboardEvent;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.events.MouseEvent;
import openfl.events.Event;
import openfl.display.Sprite;

class Main extends Sprite
{

	static var distance_threshold = 8;
	var can_draw:Bool = true;
	var shapes:Array<WiggleShape> = [];
	var cur_shape:Array<Vec2>;
	var canvas:Sprite;
	var cur_line:Sprite;
	var drawing:Bool = false;
	var line_thickness:Int = 4;
	var fill:Bool = false;
	var text:TextField;
	var palette_index_line:Int = 1;
	var palette_index_fill:Int = 8;
	var palette = [
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

	public function new()
	{
		super();
		addChild(canvas = new Sprite());
		addChild(cur_line = new Sprite());
		addChild(text = new TextField());
		text.setTextFormat(new TextFormat('consolas', 12, 0x000000, true));
		update_text();
		update_palette();
		stage.addEventListener(MouseEvent.MOUSE_DOWN, pointer_down);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, pointer_move);
		stage.addEventListener(MouseEvent.MOUSE_UP, pointer_up);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, key_down);
		stage.addEventListener(Event.ENTER_FRAME, util.UpdateManager.update);
		trace('
			CONTROLS:
			~~~~~~~~~
			UP/DOWN - line thickness
			LEFT/RIGHT - select color
			F - fill/line mode
			R - reduce last poly
			Shift+R - reduce all poly
			Ctrl+Z - undo last poly
			Ctrl+Shift+Z - clear screen
			Space - play animation
		');
		update.listen('update');
	}

	function key_down(e:KeyboardEvent) {
		trace(e.keyCode);
		if (e.keyCode == 70) change_fill();
		if (e.keyCode == 38) change_line(1);
		if (e.keyCode == 40) change_line(-1);
		if (e.keyCode == 37) get_color(-1);
		if (e.keyCode == 39) get_color(1);
		if (e.keyCode == 82) e.shiftKey ? for (shape in shapes) reduce_poly(shape.options.poly) : reduce_poly(shapes.last().options.poly);
		if (e.keyCode == 90 && e.shiftKey && e.ctrlKey) clear();
		if (e.keyCode == 90 && e.ctrlKey) undo();
		if (e.keyCode == 32) play_animation();
		if (e.keyCode == 73) input();
		if (e.keyCode == 79) output();
		update_text();
		update_palette();
	}

	function clear() {
		while (shapes.length > 0) shapes.pop().remove();
	}

	function undo() {
		shapes.pop().remove();
	}

	function change_fill() {
		fill = !fill;
	}

	function change_line(n:Int) {
		line_thickness += n;
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
		update_palette();
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

	function update_text() {
		text.text = 'mode: ${fill ? 'fill' : 'line'}\nline: ${line_thickness}';
	}

	function update_palette() {
		this.fill_circle(palette[fill ? palette_index_fill : palette_index_line], 24, 48, 16);
	}

	function reduce_poly(poly:Array<Vec2>) {
		for (i in 1...poly.length - 1) if (i % 2 == 0) poly.remove(poly[i]);
	}

	function input() {
		
	}

	function output() {
		
	}
	
}
