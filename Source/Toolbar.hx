import openfl.events.MouseEvent;
import openfl.display.Sprite;

class Toolbar extends Sprite {

	public var fill_btn:Sprite;
	public var fill_color:Sprite;
	public var line_color:Sprite;
	public var line_plus:Sprite;
	public var line_minus:Sprite;
	public var eraser:Sprite;
	public var simplify:Sprite;
	public var clear:Sprite;
	
	public function new(options:ToolbarOptions) {
		super();
		
		this.set_position(24, 48);
		this.fill_rect(Color.PICO_8_DARK_GREY, 0, -24, 248, 48, 8);

		fill_btn = new Sprite();
		fill_btn.fill_rect(Color.PICO_8_DARK_BLUE, -16, -16, 32, 32, 4);
		fill_btn.set_position(24, 0);

		fill_color = new Sprite();
		fill_color.fill_rect(Color.PICO_8_DARK_BLUE, -16, -16, 32, 32, 4);
		fill_color.set_position(64, 0);
		fill_color.visible = false;
		fill_color.addEventListener(MouseEvent.MOUSE_DOWN, (e) -> {
			Palette.i.invoke((i) -> {
				options.select_fill_color(i);
				set_fill_color(i);
				return i;
			});
		});

		line_color = new Sprite();
		line_color.fill_rect(Color.PICO_8_DARK_BLUE, -16, -16, 32, 32, 4);
		line_color.set_position(64, 0);
		line_color.addEventListener(MouseEvent.MOUSE_DOWN, (e) -> {
			Palette.i.invoke((i) -> {
				options.select_line_color(i);
				set_line_color(i);
				return i;
			});
		});
		
		var line_thickness = new Sprite();
		line_thickness.set_position(105, 0);
		var line_thickness_draw = (n) -> {
			line_thickness.graphics.clear();
			line_thickness.fill_rect(Color.PICO_8_DARK_BLUE, 0, -16, 15, 32, 4);
			line_thickness.fill_rect(Color.WHITE, 2, -n/2, 11, n);
		}
		line_thickness_draw(Main.line_thickness);

		line_plus = new Sprite();
		line_plus.fill_rect(Color.PICO_8_DARK_BLUE, -16, -16, 15, 15, 4);
		line_plus.line(Color.WHITE, -10, -8, -6, -8, 2);
		line_plus.line(Color.WHITE, -8, -10, -8, -6, 2);
		line_plus.set_position(104, 0);
		line_plus.addEventListener(MouseEvent.MOUSE_DOWN, (e) -> {
			var l = options.change_line(4);
			line_thickness_draw(l);
		});	

		line_minus = new Sprite();
		line_minus.fill_rect(Color.PICO_8_DARK_BLUE, -16, 1, 15, 15, 4);
		line_minus.line(Color.WHITE, -10, 8, -6, 8, 2);
		line_minus.set_position(104, 0);
		line_minus.addEventListener(MouseEvent.MOUSE_DOWN, (e) -> {
			var l = options.change_line(-4);
			line_thickness_draw(l);
		});	

		eraser = new Sprite();
		var eraser_icon = new Sprite();
		eraser.fill_rect(Color.PICO_8_DARK_BLUE, -16, -16, 32, 32, 4);
		eraser_icon.rect(Color.WHITE, -4, -8, 8, 16, 2, 2);
		eraser_icon.fill_rect(Color.WHITE, -4, 2, 8, 6, 2);
		eraser_icon.rotation += 45;
		eraser.addChild(eraser_icon);
		eraser.set_position(144, 0);
		eraser.addEventListener(MouseEvent.MOUSE_DOWN, (e) -> options.erase());

		simplify = new Sprite();
		simplify.fill_rect(Color.PICO_8_DARK_BLUE, -16, -16, 32, 32, 4);
		simplify.circle(Color.PICO_8_BLUE, 0, 0, 10, 2);
		simplify.rect(Color.WHITE, -6, -6, 12, 12, 0, 2);
		simplify.set_position(184, 0);
		simplify.addEventListener(MouseEvent.MOUSE_DOWN, (e) -> options.simplify());

		clear = new Sprite();
		clear.fill_rect(Color.PICO_8_RED, -16, -16, 32, 32, 4);
		clear.line(Color.WHITE, -8, -8, 8, 8, 4);
		clear.line(Color.WHITE, 8, -8, -8, 8, 4);
		clear.set_position(224, 0);
		clear.addEventListener(MouseEvent.MOUSE_DOWN, (e) -> options.clear());

		var fill = new Sprite();
		fill.fill_circle(Color.WHITE, 0, 0, 6);
		fill.visible = false;

		var line = new Sprite();
		line.circle(Color.WHITE, 0, 0, 6, 2);

		fill_btn.add(fill);
		fill_btn.add(line);

		fill_btn.addEventListener(MouseEvent.MOUSE_DOWN, (e) -> {
			var f = options.fill();
			fill.visible = f;
			line.visible = !f;
			fill_color.visible = f;
			line_color.visible = !f;
		});

		set_fill_color(options.fill_color);
		set_line_color(options.line_color);

		addChild(fill_btn);
		addChild(fill_color);
		addChild(line_color);
		addChild(line_plus);
		addChild(line_minus);
		addChild(line_thickness);
		addChild(eraser);
		addChild(simplify);
		addChild(clear);
	}

	public function set_fill_color(i:Int) {
		fill_color.circle(Color.WHITE, 0, 0, 6, 4);
		fill_color.fill_circle(Main.palette[i], 0, 0, 6);
	}

	public function set_line_color(i:Int) {
		line_color.circle(Color.WHITE, 0, 0, 6, 6);
		line_color.circle(Main.palette[i], 0, 0, 6, 2);
	}

}

typedef ToolbarOptions = {
	fill:Void -> Bool,
	fill_color:Int,
	line_color:Int,
	change_line:Int -> Int,
	erase:Void -> Void,
	simplify:Void -> Void,
	clear:Void -> Void,
	select_fill_color: Int -> Void,
	select_line_color: Int -> Void,
}