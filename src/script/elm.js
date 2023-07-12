export const getPackage = async (url) => {
    let res = await fetch(url)
    if (!res.ok) {
        res = await fetch(url.replace(/\.elm$/, ".html"))
    }

    const html = await res.text()
    const parser = new DOMParser()
    const doc = parser.parseFromString(html, "text/html")
    let code = doc.querySelector("body > script").innerText
    code = code.replace(/\}\(this\)\);/gm, "}(packageScope))")
    code = code.replace(/var app = Elm\.(.*?)\..*$/gm, "return packageScope.Elm.$1")
    code = `const packageScope = {}; ${code}`
    const fn = Function(code)

    return fn()
}
