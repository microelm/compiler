import { getPackage } from "../elm.js"
import { addEditor } from "./editor.js"
import { fetchJson } from "../fetchJson.js"

const LIST_OF_EXAMPLE = [{
    k: "Test 1 (v1.0.1)",
    v: "/examples/code/V001.txt",
}, {
    k: "Test 2 (v1.0.2)",
    v: "/examples/code/V002.txt",
}, {
    k: "Test 3 (v1.0.3)",
    v: "/examples/code/V003.txt",
}, {
    k: "Test 4 (v1.0.4)",
    v: "/examples/code/V004.txt",
}, {
    k: "Test 5 (v1.0.5)",
    v: "/examples/code/V005.txt",
}, {
    k: "Test 6 (v1.1.0)",
    v: "/examples/code/V006.txt",
}, {
    k: "Test 7 (v1.1.1)",
    v: "/examples/code/V007.txt",
}, {
    k: "Test 8 (v1.2.0)",
    v: "/examples/code/V008.txt",
}]

const LIST_OF_PARSER = [{
    k: "Compiler v1.0.1",
    v: "/examples/parser/v001.txt",
    c: "/MicroElm/V001.elm",
}, {
    k: "Compiler v1.0.2",
    v: "/examples/parser/v002.txt",
    c: "/MicroElm/V001.elm",
}, {
    k: "Compiler v1.0.3",
    v: "/examples/parser/V003.txt",
    c: "/MicroElm/V001.elm",
}, {
    k: "Compiler v1.0.4",
    v: "/examples/parser/V004.txt",
    c: "/MicroElm/V001.elm",
}, {
    k: "Compiler v1.0.5",
    v: "/examples/parser/V005.txt",
    c: "/MicroElm/V001.elm",
}, {
    k: "Compiler v1.1.0",
    v: "/examples/parser/V006.txt",
    c: "/MicroElm/V002.elm",
}, {
    k: "Compiler v1.1.1",
    v: "/examples/parser/V007.txt",
    c: "/MicroElm/V002.elm",
}]

const newLineSTR = `
`

export async function init(node) {
    const example = await fetchJson("/examples/step1.json")

    const editorCode = addEditor((v) => {
        console.log("saving editorCode")
        localStorage.code = v
    })
    const editorRuntime = addEditor((v) => {
        console.log("saving editorRuntime")
        localStorage.runtime = v
    })
    const editorParser = addEditor((v) => {
        console.log("saving editorParser")
        localStorage.parser = v
    })
    const runButton = RunButton(() => {
        return compiler.ports.messageReceiver.send([editorParser.value, editorCode.value])
    })
    const ConsoleNode = Console()
    const compilerSuccess = async (base64_string) => {
        // console.log("From Compiler", base64_string)
        const runtime = editorRuntime.value
        const bytes = Uint8Array.from(atob(base64_string), c => c.charCodeAt(0))
        const importObject = {}
        const wasm = await WebAssembly.instantiate(bytes, importObject)
        const runner = Function("wasm", "console", runtime)
        runner(wasm, {
            log(...args) {
                const replacer = (key, value) => typeof value === "bigint" ? parseInt(value.toString()) : value
                ConsoleNode.innerHTML += newLineSTR
                args.forEach((a) => {
                    ConsoleNode.innerHTML += " " +(JSON.stringify(a, replacer, 2).replaceAll("\\n", newLineSTR))
                })
                ConsoleNode.scrollTo(0, ConsoleNode.scrollHeight);

            },
        })
    }

    const compilerFail = (e) => ConsoleNode.innerHTML = `<span style="color: red">${e}</span>`
    let compiler = await initCompiler(localStorage.compilerSelected || LIST_OF_PARSER[0].c,
        compilerSuccess,
        compilerFail)

    // const selectCompiler = Select(LIST_OF_COMPILER.map(({ k }) => k), async (index) => {
    //     compiler = await initCompiler(LIST_OF_COMPILER[index].v, compilerSuccess, compilerFail)
    // })

    const selectExample = Select(LIST_OF_EXAMPLE.map(({ k }) => k), async (index) => {
        editorCode.value = await fetch(LIST_OF_EXAMPLE[index].v).then(res => res.text())
        editorRuntime.value =
            await fetch(LIST_OF_EXAMPLE[index].v.replace("/code/", "/runtime/")).then(res => res.text())
    })

    const selectParser = Select(LIST_OF_PARSER.map(({ k }) => k), async (index) => {
        localStorage.compilerSelected = LIST_OF_PARSER[index].c
        editorParser.value = await fetch(LIST_OF_PARSER[index].v).then(res => res.text())
        compiler = await initCompiler(LIST_OF_PARSER[index].c, compilerSuccess, compilerFail)
    })
    SelectCustom(selectParser, "code")
    SelectCustom(selectExample, "runtime")

    editorCode.value = localStorage.code || await Promise.resolve(example.code)
    editorRuntime.value = localStorage.runtime || example.runtime
    editorParser.value = localStorage.parser || example.parser

    node.appendChild(selectExample)
    node.appendChild(document.createElement("div")) // TODO remove me at all
    node.appendChild(selectParser)
    node.appendChild(document.createElement("div")) // TODO remove me at all

    node.appendChild(editorCode.node)
    node.appendChild(editorRuntime.node)
    node.appendChild(editorParser.node)

    node.appendChild(runButton)
    node.appendChild(ConsoleNode)
}

function SelectCustom(selectElm, key) {
    if (localStorage[key]) {
        const option = document.createElement("option")
        option.innerText = "Custom"
        option.value = "-1"
        option.disabled = true
        option.selected = true
        selectElm.appendChild(option)
    }
}

async function initCompiler(url, success, fail) {
    const Package = await getPackage(url)
    const packageName = url.match(/\/([^\/]*)\.elm$/)[1]
    const app = Package[packageName].init()
    app.ports.sendError.subscribe(fail)
    app.ports.sendMessage.subscribe(success)

    return app
}

function Select(options, onChange) {
    const select = document.createElement("select")

    options.forEach((key, value) => {
        const option = document.createElement("option")
        option.innerText = key
        option.value = value
        select.appendChild(option)
    })
    select.addEventListener("change", (e) => onChange(e.target.value))

    return select
}

function RunButton(onClick) {
    const runButton = document.createElement("button")
    runButton.innerText = "Run"
    runButton.addEventListener("click", onClick)

    return runButton
}

function Console() {
    const div = document.createElement("div")
    div.innerText = "Im console"
    div.style.whiteSpace = "pre"
    div.style.overflow = "auto"
    div.style.paddingBottom = "3em"

    return div
}
