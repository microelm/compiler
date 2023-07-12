export const fetchJson = async (url) => {
    const res = await fetch(url)
    return res.json()
}
