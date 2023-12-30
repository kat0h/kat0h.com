/*
    click     : クリックした時
    dbclick   : ダブルクリックした時
    mousedown : マウスを押した時（クリックした時）
    mouseup   : マウスを離した時（クリック後）
    mousemove : マウスが動いた時
    mouseover : マウスが乗った時
    mouseout  : マウスが外れた時
*/

const canvas_height = 300;
const canvas_width  = 300;

const canvas = document.getElementById("c");
const ctx = canvas.getContext("2d");

// パスは点の集合
const path = [];
let count = 0;

canvas.height = canvas_height;
canvas.width  = canvas_width;

canvas.addEventListener("mousedown", (e) => {
});

const updateCanvas = () => {
  count += 1;
  ctx.fillStyle = "black";
  ctx.clearRect(0, 0, canvas_width, canvas_height);
  ctx.fillText(`${count}`, 0, canvas_height);
  if (path.length < 2) return;
}

updateCanvas();
