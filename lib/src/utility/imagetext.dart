import "dart:html";

class ImageText {
	ImageElement source;
	Map<String,int> offsets = {};
	Map<String,int> widths = {};
	Set<String> glyphs = new Set<String>();
	Map<String,int> kerning = {};
	
	int width;
	int height;
	int spacewidth;
	int spacing;
	
	ImageText(ImageElement this.source, String glyphstring, int this.spacewidth, int this.spacing) {
		List<String> splitglyphs = glyphstring.split("");
		glyphs.addAll(splitglyphs);
		
		this.width = source.width;
		this.height = source.height;
		
		CanvasElement canvas = new CanvasElement()..width = this.source.width..height = this.source.height;
		CanvasRenderingContext2D ctx = canvas.context2D;
		
		ctx.drawImage(this.source, 0, 0);
		
		ImageData idata = ctx.getImageData(0, 0, source.width, 1);
		
		int o,r,g,b,a;
		int place = 0;
		int left = 0;
		String glyph;
		for (int i=0; i<source.width; i++) {
			o = i*4;
			r = idata.data[o];
			g = idata.data[o+1];
			b = idata.data[o+2];
			a = idata.data[o+3];
			
			/*//ctx.fillStyle = "rgb($r,$g,$b)";
			//ctx.fillStyle = "rgb($a,$a,$a)";
			ctx.fillStyle="black";
			if (r == 255 && g == 0 && b == 0 && a > 127) {
				ctx.fillStyle = "red";
				print (a);
			}
			ctx.fillRect(i, 1, 1, height-1);*/
			
			if (r == 255 && g == 0 && b == 0 && a > 127) {
				if (place < splitglyphs.length) {
					glyph = splitglyphs[place];
					offsets[glyph] = left;
					widths[glyph] = i-left-1;
					left = i+1;
					place++;
				}
			}
		}
		
		if (splitglyphs.length > 1) {
			String last = splitglyphs[splitglyphs.length-1];
			String prev = splitglyphs[splitglyphs.length-2];
			
			offsets[last] = offsets[prev] + widths[prev] + 2;
			widths[last] = source.width - offsets[last] - 1;
		}
		
		/*print(splitglyphs);
		print(this.widths);
		print(this.offsets);
		
		querySelector("#container").append(canvas);*/
	}
	
	void setKerning(String char, int offset) {
		this.kerning[char] = offset;
	}
	
	Element build(String input, [double scale=1.0]) {
		List<String> words = input.split(" ");
		
		DivElement stringdiv = new DivElement()..className="imagetext_string";

		String word;
		for(int i=0; i<words.length; i++) {
			word = words[i];
			List<String> chars = word.split("");
			
			DivElement worddiv = new DivElement()..className="imagetext_word";
			
			bool first = true;
			
			for (String char in chars) {
				if (this.glyphs.contains(char)) {
					// image glyph
					DivElement glyphdiv = new DivElement()..className="imagetext_glyph";
					
					glyphdiv.style
						..width = "${(widths[char] * scale).floor()}px"
						..height = "${(height * scale).floor()}px"
						..backgroundImage = "url('${this.source.src}')"
						..backgroundPositionX = "${-(offsets[char] * scale).ceil()}px"
						..backgroundSize = "${(width * scale).floor()}px ${(height * scale).floor()}px"
						..marginRight = "${(spacing * scale).ceil()}px";
						
					
					if (!first && kerning.containsKey(char)) {
						glyphdiv.style.marginLeft = "${(kerning[char] * scale).round()}px";
					}
					
					//glyphdiv.text=char;
					
					worddiv.append(glyphdiv);
				} else {
					// PALE IMITATION!
					DivElement glyphdiv = new DivElement()..className="imagetext_glyph";
					
					glyphdiv
						..style.height = "${(height * scale).floor()}px"
						..style.fontSize = "${(height * scale).floor()}px"
						..text = char;
						
					worddiv.append(glyphdiv);
				}
				
				first = false;
			}
			
			stringdiv.append(worddiv);
			
			if (i < words.length-1) {
				DivElement spacediv = new DivElement()..className="imagetext_space";
				
				spacediv.style.width = "${(spacewidth * scale).toInt()}px";
				
				//spacediv.text="-";
				
				stringdiv.append(spacediv);
			}
		}
		
		return stringdiv;
	}
}