var host = document.querySelector("#shadow-root");

var root = host.attachShadow({ mode: "open" });

root.innerHTML = `
<style>
p {
    color: red;
}
</style>
<p>Hello F8</p>
`;
