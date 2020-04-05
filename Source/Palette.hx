import openfl.events.MouseEvent;
import openfl.display.Sprite;

class Palette extends Sprite {

	var on_select:Int -> Int;
	public static var i:Palette;

	public function new() {
		super();
		i = this;
		this.fill_rect(Color.PICO_8_DARK_GREY, 0, 0, 180, 180, 8);
		this.set_position(24, 80);
		for (i in 0...16) {
			var color = new Sprite();
			color.fill_circle(Main.palette[i], i % 4 * 40 + 30, (i / 4).floor() * 40 + 30, 16);
			color.circle(Color.BLACK, i % 4 * 40 + 30, (i / 4).floor() * 40 + 30, 16, 4);
			color.addEventListener(MouseEvent.MOUSE_DOWN, (e) -> select(i));
			addChild(color);
		}
		visible = false;
	}

	public function invoke(fn:Int -> Int) {
		visible = true;
		on_select = fn;
	}

	function select(i:Int) {
		on_select(i);
		visible = false;
	}

}