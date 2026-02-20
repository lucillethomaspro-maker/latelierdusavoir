const btn = document.getElementById("burger");

btn.addEventListener("click", () => {
  const isOpen = btn.classList.toggle("is-open");
  btn.setAttribute("aria-expanded", isOpen);
});
