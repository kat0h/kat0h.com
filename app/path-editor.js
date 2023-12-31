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
const canvas_width = 300;
const rectSize = 5;

const canvas = document.getElementById("c");
const ctx = canvas.getContext("2d");

// パスは点の集合
const paths = [[]];
let count = 0;

canvas.height = canvas_height;
canvas.width = canvas_width;

let state = "none";
/*
 * draw, move
 */
let mode = "";
let movestate = "";
let movingpoint = undefined;
let mousepos = [0, 0];
let mouseposd = [0, 0];

const isWithinRange = (value, value2, error) => {
  return value2[0] - error <= value[0] && value2[0] + error >= value[0] &&
    value2[1] - error <= value[1] && value2[1] + error >= value[1];
};

const distance = (p1, p2) => ((p1[0] - p2[0]) ** 2 + (p1[1] - p2[1]) ** 2);
const minOrInf = (ary) =>
  ary.length == 0 ? Infinity : ary.reduce((a, b) => Math.min(a, b));
const findMinIndex = (ary) =>
  ary.length == 0 ? -1 : ary.indexOf(ary.reduce((a, b) => Math.min(a, b)));
const arrayEqual = (arr1, arr2) => JSON.stringify(arr1) == JSON.stringify(arr2);
const pathIsClosed = (p) => p[0] == p[p.length - 1];

const findNearestPoint = (point) => {
  const len = paths.map((path) => path.map((p) => distance(p, point)));
  const r1 = findMinIndex(len.map((l) => {
    if (l.length == 0) {
      return Infinity;
    } else {
      return minOrInf(l);
    }
  }));
  const r2 = r1 == -1 ? -1 : findMinIndex(len[r1]);
  return [r1, r2];
};

const mousedownDraw = (e) => {
  if (
    paths[paths.length - 1].length > 2 &&
    isWithinRange([e.offsetX, e.offsetY], paths[paths.length - 1][0], rectSize)
  ) {
    paths[paths.length - 1].push(paths[paths.length - 1][0]);
    nextSubPath();
  } else {
    paths[paths.length - 1].push([e.offsetX, e.offsetY]);
  }
};

const mousedownDelete = () => {
  const near = findNearestPoint(mousepos);
  // 消せる点がある
  if (
    near[0] != -1 && near[1] != -1 &&
    isWithinRange(paths[near[0]][near[1]], mousepos, rectSize)
  ) {
    const p = paths[near[0]];
    if (pathIsClosed(paths[near[0]]) && near[1] == 0) {
      p.splice(0, 1);
      p.splice(p.length - 1, 1);
      if (p.length > 2) {
        p.push(p[0]);
      }
    } else {
      p.splice(near[1], 1);
      if (p.length == 3 && pathIsClosed) {
        p.splice(0, 1);
      }
    }
    if (p.length < 2 || (p.length == 2 && pathIsClosed(p))) {
      paths.splice(near[0], 1);
    }
  }
};

canvas.addEventListener("mousedown", (e) => {
  if (mode == "draw") {
    mousedownDraw(e);
  } else if (mode == "move") {
    movestate = "down";
    const near = findNearestPoint(mousepos);
    // 動かせる点がある
    if (
      isWithinRange(paths[near[0]][near[1]], mousepos, rectSize) &&
      near[0] != -1 && near[1] != -1
    ) {
      movingpoint = near;
    } else {
      // 点の追加
      const liness = paths.map((path) => {
        if (path.length < 2) {
          return [];
        }
        const ret = [];
        for (let i = 0; i < path.length - 1; i++) {
          const a = path[i];
          const b = path[i + 1];
          ret.push([
            (b[1] - a[1]) / (b[0] - a[0]),
            -1,
            a[1] - (b[1] - a[1]) / (b[0] - a[0]) * a[0],
          ]);
        }
        return ret;
      });
      const distance = liness.map((lines) =>
        lines.map((line) =>
          Math.abs(line[0] * mousepos[0] + line[1] * mousepos[1] + line[2]) /
          Math.sqrt(line[0] ** 2 + line[1] ** 2)
        )
      );
      const r1 = findMinIndex(distance.map((d) => minOrInf(d)));
      const r2 = r1 == -1 ? -1 : findMinIndex(distance[r1]);
      if (r1 != -1 && r2 != -1 && distance[r1][r2] <= 5) {
        paths[r1].splice(r2 + 1, 0, [...mousepos]);
      }
    }
  } else if (mode == "delete") {
    mousedownDelete();
  }
  updateCanvas();
});

canvas.addEventListener("mouseup", (e) => {
  if (mode == "move") {
    movestate = "up";
    movingpoint = undefined;
  }
});

canvas.addEventListener("mousemove", (e) => {
  state = "mousemove";
  mousepos = [e.offsetX, e.offsetY];
  mouseposd = [e.movementX, e.movementY];
  if (mode == "draw") {
  } else if (mode == "move") {
    if (movestate == "down" && movingpoint != undefined) {
      const p = paths[movingpoint[0]];
      p[movingpoint[1]][0] = mousepos[0];
      p[movingpoint[1]][1] = mousepos[1];
    }
  }
  updateCanvas();
});

const clearCanvas = () => {
  ctx.clearRect(0, 0, canvas_width, canvas_height);
};

const nextSubPath = () => {
  if (paths[paths.length - 1].length > 1) {
    paths.push([]);
  }
  updateCanvas();
};

const changeMode = (newMode) => {
  if (mode == newMode) {
    return;
  }
  if (paths[paths.length - 1].length == 1) {
    paths[paths.length - 1] = [];
  }
  if (newMode == "draw") {
    mode = "draw";
    canvas.style.cursor = "default";
  } else if (newMode == "move") {
    mode = "move";
    movestate = "up";
    canvas.style.cursor = "defaut";
  } else if (newMode == "delete") {
    mode = "delete";
    canvas.style.cursor = "default";
  }
  document.getElementById("mode").innerHTML = mode;
  updateCanvas();
};

const updateCanvas = () => {
  count += 1;
  clearCanvas();
  ctx.fillStyle = "black";
  ctx.fillText(`${count}`, 0, canvas_height);

  const nearP = findNearestPoint(mousepos);

  ctx.beginPath();
  paths.forEach((path, i) => {
    if (path.length < 1) return;
    // draw rectangle
    path.forEach((pos, j) => {
      if (i == nearP[0] && j == nearP[1]) {
        if (isWithinRange(paths[nearP[0]][nearP[1]], mousepos, rectSize)) {
          ctx.strokeStyle = "blue";
        } else {
          ctx.strokeStyle = "red";
        }
      }
      if (j == 0 || !arrayEqual(path[0], path[j])) {
        ctx.strokeRect(
          pos[0] - rectSize,
          pos[1] - rectSize,
          rectSize * 2,
          rectSize * 2,
        );
      }
      if (i == nearP[0] && j == nearP[1]) {
        ctx.strokeStyle = "black";
      }
    });
    // draw lines
    ctx.moveTo(...path[0]);
    for (let i = 1; i < path.length; i++) {
      ctx.lineTo(...path[i]);
    }
    // 最初の要素と最後の要素が一致していたらパスを閉じる
    if (pathIsClosed(path)) {
      ctx.closePath();
    }
    if (state == "mousemove" && mode == "draw" && i == paths.length - 1) {
      ctx.lineTo(...mousepos);
    }
  });
  ctx.stroke();

  // test
  if (mode == "move") {
    const liness = paths.map((path) => {
      if (path.length < 2) {
        return [];
      }
      const ret = [];
      for (let i = 0; i < path.length - 1; i++) {
        const a = path[i];
        const b = path[i + 1];
        ret.push([
          (b[1] - a[1]) / (b[0] - a[0]),
          -1,
          a[1] - (b[1] - a[1]) / (b[0] - a[0]) * a[0],
        ]);
      }
      return ret;
    });
    const distance = liness.map((lines) =>
      lines.map((line) =>
        Math.abs(line[0] * mousepos[0] + line[1] * mousepos[1] + line[2]) /
        Math.sqrt(line[0] ** 2 + line[1] ** 2)
      )
    );
    if (minOrInf(distance.flat(1 / 0)) <= 5) {
      canvas.style.cursor = "pointer";
    } else {
      canvas.style.cursor = "default";
    }
  }

  document.getElementById("log").innerHTML = `${JSON.stringify(paths)}`;
};

changeMode("draw");
nextSubPath();
updateCanvas();
