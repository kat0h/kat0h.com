function fixLinksHeight() {
	const links = document.getElementById("links");
	links.style.height = links.children[0].contentWindow.document.body.scrollHeight + "px";
	links.children[0].style.height = links.children[0].contentWindow.document.body.scrollHeight + "px";
}