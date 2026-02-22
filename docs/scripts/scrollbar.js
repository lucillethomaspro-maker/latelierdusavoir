const main = document.querySelector("main");

function updateMainHeight() {
  console.log("On recalcule, s'il vous plait");
  main.style.setProperty("--main-height", `${main.offsetHeight}px`);
}

let resizeTimer;

window.addEventListener("resize", () => {
  clearTimeout(resizeTimer);
  resizeTimer = setTimeout(updateMainHeight, 100);
});

updateMainHeight();
