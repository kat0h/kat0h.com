import pdfjsDist from 'https://cdn.jsdelivr.net/npm/pdfjs-dist@5.0.375/+esm';
var {pdfjsLib}=globalThis;
const gebid=id=>document.getElementById(id);
pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdn.jsdelivr.net/npm/pdfjs-dist@5.0.375/build/pdf.worker.min.mjs';
const mkviewer=async(id,pdf)=>{
  gebid(id).innerHTML=`<canvas id='${id}-canvas'></canvas><button id='${id}-prev'>Prev</button><button id='${id}-next'>Next</button><span id='${id}-stat'></span>`;
  const doc=await(await pdfjsLib.getDocument(pdf)).promise;
  const canvas=gebid(`${id}-canvas`);
  const context=canvas.getContext('2d');
  var index=1,rendering=false;
  const render=async pagei=>{
    if(rendering)return;rendering=true;
    const page=await doc.getPage(pagei);
    const viewport=page.getViewport({scale:1});
    canvas.height=viewport.height;canvas.width=viewport.width;
    canvas.style.width=viewport.width+"px";canvas.style.height=viewport.height+"px";
    const renderContext={canvasContext:context,viewport:viewport};
    await page.render(renderContext);
    gebid(`${id}-stat`).innerText=`Page:${index}/${doc.numPages}`;
    rendering=false;
  }
  await render(index);
  Object.entries({prev:()=>render(index=index-(index<=1?0:1)),next:()=>render(index=index+(index>=doc.numPages?0:1))})
    .forEach(([k,v])=>gebid(`${id}-${k}`).addEventListener('click',v));
}
const mkviewerFromFile=async (id,file)=>mkviewer(id,{
    data:await file.bytes(),cMapPacked:true,
    cMapUrl:'https://cdn.jsdelivr.net/npm/pdfjs-dist@5.0.375/cmaps/',
});
const file2dataUrl=async file=>{
  const reader=new FileReader();reader.readAsDataURL(file);
  await new Promise(r=>reader.onload=()=>r());
  return reader.result;
}
