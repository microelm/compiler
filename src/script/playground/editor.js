function update(text, result_element) {
    // let result_element = document.querySelector("#highlighting-content")
    // Handle final newlines (see article)
    if (text[text.length - 1] === "\n") {
        text += " "
    }
    // Update code
    text = text.replace(new RegExp("&", "g"), "&amp;").replace(new RegExp("<", "g"), "&lt;") /* Global RegExp */

    // Syntax Highlight
    // let regex = /^([^& ]*)([^&]*)&lt;-/mig
    // text = text.replace(regex, "<span style='color: red'>$1</span>$2<-")
    result_element.innerHTML = text

}

function sync_scroll(element, result_element) {
    /* Scroll result to scroll coords of event - sync with textarea */
    // let result_element = document.querySelector("#highlighting")
    // Get and set x and y
    result_element.scrollTop = element.scrollTop
    result_element.scrollLeft = element.scrollLeft
}

function check_tab(element, event, result_element) {
    let code = element.value
    if (event.key === "Tab") {
        /* Tab key pressed */
        event.preventDefault() // stop normal
        let before_tab = code.slice(0, element.selectionStart) // text before tab
        let after_tab = code.slice(element.selectionEnd, element.value.length) // text after tab
        let cursor_pos = element.selectionStart + 1 // where cursor moves after tab - moving forward by 1 char to after tab
        element.value = before_tab + "\t" + after_tab // add tab char
        // move cursor
        element.selectionStart = cursor_pos
        element.selectionEnd = cursor_pos
        update(element.value, result_element) // Update text to include indent
    }
}

export function addEditor(onChange) {
    const wrapper = document.createElement("div")
    // wrapper.style.height = "400px"
    wrapper.style.position = "relative"
    // wrapper.style.margin = "10px"

    const onInput = () => {
        if (typeof onChange === "function") {
            onChange(textarea.value)
        }
        update(textarea.value, code)
        sync_scroll(textarea, pre)
    }
    const textarea = document.createElement("textarea")
    textarea.setAttribute("data-gramm", "false")
    textarea.setAttribute("placeholder", "Enter HTML Source Code")
    textarea.className = "editing"
    textarea.setAttribute("spellcheck", "false")
    textarea.addEventListener("input", onInput)
    textarea.addEventListener("scroll", () => {
        sync_scroll(textarea, pre)
    })
    textarea.addEventListener("keydown", (e) => {
        check_tab(textarea, e, code)
    })

    const pre = document.createElement("pre")
    pre.className = "highlighting"
    pre.setAttribute("aria-hidden", "false")

    const code = document.createElement("code")
    pre.appendChild(code)
    wrapper.appendChild(textarea)
    wrapper.appendChild(pre)

    return {
        node: wrapper, get value() {
            return textarea.value
        }, set value(v) {
            textarea.value = v
            onInput()
        },
    }
}

function init() {
    document.getElementById("editing").innerHTML = grammar
    update(document.getElementById("editing").value)
    sync_scroll(document.getElementById("editing"))
}
