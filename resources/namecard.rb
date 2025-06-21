# Kota Kato
#  X: @kat0h
# HP: kat0h.com

ascii_qr_code = <<~QR
##############  ######      ##  ##  ##############
##          ##    ##            ##  ##          ##
##  ######  ##    ##      ######    ##  ######  ##
##  ######  ##      ########  ####  ##  ######  ##
##  ######  ##              ##  ##  ##  ######  ##
##          ##    ########          ##          ##
##############  ##  ##  ##  ##  ##  ##############
                ##    ##  ##  ####                
####  ####  ##    ########  ##  ##  ##          ##
####  ##  ##  ##########      ##      ##########  
  ########  ##  ##  ####  ##############  ##    ##
####    ##    ##  ####        ####  ##  ##########
##    ##    ########    ##    ####  ####        ##
##  ########    ##    ######  ######    ##    ##  
######    ####  ####      ############  ##########
##    ##  ##  ############  ####    ####  ####  ##
##  ##  ##  ##  ####  ##  ##    ##########  ####  
                ##        ##    ##      ##  ####  
##############    ##  ##  ####  ##  ##  ##      ##
##          ##    ##      ##    ##      ##    ##  
##  ######  ##  ##  ##  ##  ##############    ##  
##  ######  ##  ####  ##    ##  ##  ##        ####
##  ######  ##    ##  ############      ##########
##          ##  ##    ##    ##    ########  ######
##############  ####    ##      ######    ##    ##
QR

class String
  def extract_odd_bytes
    self.bytes.each_with_index.select { |_, i| i.even? }.map(&:first).pack('C*')
  end
end

qr_dat = ascii_qr_code
  .split("\n")
  .map{
    it.extract_odd_bytes.chars.map{
      it=="#"?1:0
    }
  }

Block_table = {
  0b0000 => " ",
  0b0001 => "▗",
  0b0010 => "▖",
  0b0011 => "▄",
  0b0100 => "▝",
  0b0101 => "▐",
  0b0110 => "▞",
  0b0111 => "▟",
  0b1000 => "▘",
  0b1001 => "▚",
  0b1010 => "▌",
  0b1011 => "▙",
  0b1100 => "▀",
  0b1101 => "▜",
  0b1110 => "▛",
  0b1111 => "█",
}

Font = Struct.new :size, :dat

Font3X5 = Font.new(
  size: [3, 5],
  dat: {
    "A" => [[0,1,0], [1,0,1], [1,1,1], [1,0,1], [1,0,1]],
    "B" => [[1,1,0], [1,0,1], [1,1,0], [1,0,1], [1,1,0]],
    "C" => [[0,1,1], [1,0,0], [1,0,0], [1,0,0], [0,1,1]],
    "H" => [[1,0,1], [1,0,1], [1,1,1], [1,0,1], [1,0,1]],
    "E" => [[1,1,1], [1,0,0], [1,1,1], [1,0,0], [1,1,1]],
    "L" => [[1,0,0], [1,0,0], [1,0,0], [1,0,0], [1,1,1]],
    "O" => [[1,1,1], [1,0,1], [1,0,1], [1,0,1], [1,1,1]],
    "!" => [[0,1,1], [0,1,1], [0,1,1], [0,0,0], [0,1,1]]
  }
)

Font5x7 = Font.new(
  size: [5, 7],
  dat: {
    "K" => [
      "#   #",
      "#  # ",
      "# #  ",
      "##   ",
      "# #  ",
      "#  # ",
      "#   #",
    ],
    "k" => [
      "#   ",
      "#   ",
      "#  #",
      "# # ",
      "##  ",
      "# # ",
      "#  #",
    ],
    "H" => [
      "#   #",
      "#   #",
      "#   #",
      "#####",
      "#   #",
      "#   #",
      "#   #",
    ],
    "P" => [
      "#### ",
      "#   #",
      "#   #",
      "#### ",
      "#    ",
      "#    ",
      "#    ",
    ],
    "X" => [
      "#   #",
      "#   #",
      " # # ",
      "  #  ",
      " # # ",
      "#   #",
      "#   #",
    ],
    "o" => [
      "     ",
      "     ",
      " ### ",
      "#   #",
      "#   #",
      "#   #",
      " ### ",
    ],
    "t" => [
      "     ",
      "  #  ",
      "#####",
      "  #  ",
      "  #  ",
      "  #  ",
      "   ##",
    ],
    "a" => [
      "     ",
      " ### ",
      "    #",
      " ####",
      "#   #",
      "#  ##",
      " ## #",
    ],
    "h" => [
      "#    ",
      "#    ",
      "# ## ",
      "##  #",
      "#   #",
      "#   #",
      "#   #",
    ],
    "0" => [
      " ### ",
      "#   #",
      "##  #",
      "# # #",
      "#  ##",
      "#   #",
      " ### ",
    ],
    "c" => [
      "     ",
      "     ",
      " ### ",
      "#   #",
      "#    ",
      "#   #",
      " ### ",
    ],
    "m" => [
      "     ",
      "     ",
      "## # ",
      "# # #",
      "# # #",
      "# # #",
      "# # #",
    ],
    "." => [
      "  ",
      "  ",
      "  ",
      "  ",
      "  ",
      "  ",
      "##",
    ],
    ":" => [
      "  ",
      "##",
      "  ",
      "  ",
      "##",
      "  ",
      "  ",
    ],
    " " => [
      "     ",
      "     ",
      "     ",
      "     ",
      "     ",
      "     ",
      "     ",
    ],
    "@" => [
      " ### ",
      "#   #",
      "#  ##",
      "# # #",
      "# ###",
      "#    ",
      " ####",
    ],
  }.map{|k,v|[k,v.map{it.chars.map{it==" "?0:1}}]}.to_h
)

def merge_font_data_with_spacing(text, font: Font3X5)
  height = font.size[1]
  space = [0] * font.size[0]
  font_rows = Array.new(height) { [] }
  text.chars.each_with_index do |char, idx|
    glyph = font.dat[char] || Array.new(height) { [0] * font.size[0] }
    glyph.each_with_index do |row, i|
      font_rows[i] += row
      font_rows[i] += [0] if idx < text.length - 1
    end
  end

  font_rows
end

def render_with_block_table(merged_data)
  output_lines = []
  (0...(merged_data.size)).step(2) do |y|
    line = ""
    (0...(merged_data[0].size)).step(2) do |x|
      tl = merged_data.dig(y, x).to_i
      tr = merged_data.dig(y, x + 1).to_i
      bl = merged_data.dig(y + 1, x).to_i
      br = merged_data.dig(y + 1, x + 1).to_i
      bits = (tl << 3) | (tr << 2) | (bl << 1) | br
      line << (Block_table[bits] || "?")  # 表示
    end
    output_lines << line
  end
  output_lines
end
merged_data = merge_font_data_with_spacing("HELLO!")
# render_with_block_table(merged_data)
# render_with_block_table(qr_dat)


jelly_fish = [
  "  ###      ",
  " #   ##    ",
  "#    # ##  ",
  "#   ##   ##",
  " ###  #    ",
  "   #   #   ",
  "    #      ",
].map{it.chars.map{it==" "?0:1}}

def paste_bitmap(canvas, bitmap, x_offset, y_offset)
  canvas_height = canvas.size
  canvas_width  = canvas[0].size
  bitmap_height = bitmap.size
  bitmap_width  = bitmap[0].size

  bitmap.each_with_index do |row, dy|
    cy = y_offset + dy
    next if cy < 0 || cy >= canvas_height

    row.each_with_index do |val, dx|
      cx = x_offset + dx
      next if cx < 0 || cx >= canvas_width

      canvas[cy][cx] = val
    end
  end

  canvas
end

def merge_multiline_text(lines, font:, line_spacing: 1)
  glyph_height = font.size[1]
  space_rows = Array.new(line_spacing) { [0] * 1 }  # 空行（幅はあとで補正される）

  result = []

  lines.each_with_index do |line, idx|
    bitmap = merge_font_data_with_spacing(line, font: font)
    result += bitmap
    result += space_rows if idx < lines.size - 1
  end

  # 各行の長さを揃える（右側に0を補完）
  max_width = result.map(&:size).max
  result.map! { |row| row + [0] * (max_width - row.size) }

  result
end

lines = [
  "Kota Kato",
  "X : @kat0h",
  "HP: kat0h.com",
]

merged_bitmap = merge_multiline_text(lines, font: Font5x7, line_spacing: 1)

puts "generated data"
puts "=========================="
# 40x20 のキャンバス（0で初期化）
size = [25, 100]
canvas = Array.new(size.first) { Array.new(size.last, 0) }

paste_bitmap(canvas, qr_dat, 0, 0)
paste_bitmap(canvas, merged_bitmap, 30, 1)
paste_bitmap(canvas, jelly_fish, 89, 0)

puts render_with_block_table(canvas).join("\n")
puts "=========================="

B=(0..16).zip(" ▗▖▄▝▐▞▟▘▚▌▙▀▜▛█".chars).to_h
r=->(a){a.flat_map{|r|[[],[]].zip(*r.chars.map{|c|b=(B.invert[c]||0);[[b>>3&1,b>>2&1],[b>>1&1,b&1]]}).map(&:flatten)}};
n=->(g){h,w=g.size,g[0].size;d=(d=[-1,0,1]).product(d)-[[0,0]];(0...h).map{|y|(0...w).map{|x|l,c=d.count{g[(y+_1)%h][(x+_2)%w]==1},g[y][x];(c==1&&l==2||l==3)||(c==0&&l==3)?1:0}}}
s=->(g){
  g.each_slice(2).map{|r|
    (0...r[0].size).step(2).map{|x|
      b=->y,z{r[y]&.[](x+z).to_i}
      B[(b[0,0]<<3)|(b[0,1]<<2)|(b[1,0]<<1)|b[1,1]]||"?"
    }.join
  }
}
dat = [
  "▛▀▀▌▜▘ ▘▌▛▀▀▌  ▖ ▖            ▖ ▖            ▞▀▄  ",
  "▌█▌▌▝▄▟▜▖▌█▌▌  ▌▞ ▗▄ ▄▙▖▝▀▖   ▌▞ ▝▀▖▄▙▖▗▄   ▐ ▗▌▀▄",
  "▌▀▘▌▗▄▖▘▘▌▀▘▌  ▛▖ ▌ ▌ ▌ ▞▀▌   ▛▖ ▞▀▌ ▌ ▌ ▌   ▀▌▝▖ ",
  "▀▀▀▘▌▚▚▚▌▀▀▀▘  ▌▝▖▚▄▘ ▚▖▚▞▌   ▌▝▖▚▞▌ ▚▖▚▄▘    ▝   ",
  "█▐▚▚▟█▘▚▘▚▄▄▘  ▖ ▖        ▄▖▗        ▗▄ ▖         ",
  "▟▀▌▚▚▛▝▜▛▛▟▄▌  ▚▗▘   ▀   ▐ ▟▐ ▖▝▀▖▄▙▖▙ ▌▌▄        ",
  "▌▟▄▀▛▗▙▐▙▀▖▗▘  ▗▚    ▄   ▐▐▟▐▞ ▞▀▌ ▌ ▌▚▌▛ ▌       ",
  "▛▚▐▚█▄▞█▀▙▜▛▌  ▌ ▌       ▝▄▄▐▝▖▚▞▌ ▚▖▚▄▘▌ ▌       ",
  "▘▘▘▘▛▝▐ ▛▀▌█   ▖ ▖▄▄     ▗        ▗▄ ▖            ",
  "▛▀▀▌▐▝▐▘▌▘▌▗▘  ▌ ▌▌ ▌▀   ▐ ▖▝▀▖▄▙▖▙ ▌▌▄   ▄▖ ▄▖▗▖▖",
  "▌█▌▌▙▚▘▛▛▛▘▐▖  ▛▀▌▛▀ ▄   ▐▞ ▞▀▌ ▌ ▌▚▌▛ ▌ ▐ ▝▐ ▐▐▐▐",
  "▌▀▘▌▞▐▀▛▚▄▛█▌  ▌ ▌▌      ▐▝▖▚▞▌ ▚▖▚▄▘▌ ▌▄▝▄▞▝▄▞▐▐▐",
  "▀▀▀▘▀ ▘ ▀▘▝ ▘                                     ",
]
p dat
puts s.(n.(r.(dat))).join("\n")




# loop {
#   puts render_with_block_table(canvas=n.(canvas)).join("\n")
#   sleep(0.1)
#   system('clear')
# }

# eval$s="puts'eval$s='<<34<<$s<<34;r=->(a){a.flat_map{
# |r|[[],[]].zip(*r.chars.map{|c|b=(Block_table.invert[
# c]||0);[[b>>3&1,b>>2&1],[b>>1&1,b&1]]}).map(&:flatten
# )}};n=->(g){h,w=g.size,g[0].size;d=(d=[-1,0,1])
# .product(d)-[[0,0]];(0...h).map{|y|(0...w).map{|x|l,c
# =d.count{g[(y+_1)%h][(x+_2)%w]==1},g[y][x];(c==1&&l==
# 2||l==3)||(c==0&&l==3)?1:0}}};exit
#
# ▛▀▀▌▜▘ ▘▌▛▀▀▌  ▖ ▖            ▖ ▖            ▞▀▄  
# ▌█▌▌▝▄▟▜▖▌█▌▌  ▌▞ ▗▄ ▄▙▖▝▀▖   ▌▞ ▝▀▖▄▙▖▗▄   ▐ ▗▌▀▄
# ▌▀▘▌▗▄▖▘▘▌▀▘▌  ▛▖ ▌ ▌ ▌ ▞▀▌   ▛▖ ▞▀▌ ▌ ▌ ▌   ▀▌▝▖ 
# ▀▀▀▘▌▚▚▚▌▀▀▀▘  ▌▝▖▚▄▘ ▚▖▚▞▌   ▌▝▖▚▞▌ ▚▖▚▄▘    ▝   
# █▐▚▚▟█▘▚▘▚▄▄▘  ▖ ▖        ▄▖▗        ▗▄ ▖         
# ▟▀▌▚▚▛▝▜▛▛▟▄▌  ▚▗▘   ▀   ▐ ▟▐ ▖▝▀▖▄▙▖▙ ▌▌▄        
# ▌▟▄▀▛▗▙▐▙▀▖▗▘  ▗▚    ▄   ▐▐▟▐▞ ▞▀▌ ▌ ▌▚▌▛ ▌       
# ▛▚▐▚█▄▞█▀▙▜▛▌  ▌ ▌       ▝▄▄▐▝▖▚▞▌ ▚▖▚▄▘▌ ▌       
# ▘▘▘▘▛▝▐ ▛▀▌█   ▖ ▖▄▄     ▗        ▗▄ ▖            
# ▛▀▀▌▐▝▐▘▌▘▌▗▘  ▌ ▌▌ ▌▀   ▐ ▖▝▀▖▄▙▖▙ ▌▌▄   ▄▖ ▄▖▗▖▖
# ▌█▌▌▙▚▘▛▛▛▘▐▖  ▛▀▌▛▀ ▄   ▐▞ ▞▀▌ ▌ ▌▚▌▛ ▌ ▐ ▝▐ ▐▐▐▐
# ▌▀▘▌▞▐▀▛▚▄▛█▌  ▌ ▌▌      ▐▝▖▚▞▌ ▚▖▚▄▘▌ ▌▄▝▄▞▝▄▞▐▐▐
# ▀▀▀▘▀ ▘ ▀▘▝ ▘                                     
# "
#
