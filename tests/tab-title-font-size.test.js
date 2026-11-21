const { describe, it } = require('node:test')
const assert = require('node:assert/strict')
const { STYLE_TEXT } = require('../src/ui/styles.js')
const { normalizeSettingValue, TAB_TITLE_FONT_SIZES } = require('../src/ui/render.js')

function cssRule(selector) {
  const match = STYLE_TEXT.split(`${selector} {`)[1]
  assert.ok(match, `expected stylesheet to define ${selector}`)
  return match.split('}')[0]
}

describe('tab title font size - stylesheet', () => {
  it('drives the tab title font size from --svb-tab-title-font-size', () => {
    assert.ok(cssRule('#svb-root .svb-tab__title').includes('font-size: var(--svb-tab-title-font-size, 13px);'))
  })

  it('drives the inline rename field from the same variable', () => {
    const rule = cssRule('#svb-root .svb-tab__title-input')
    assert.ok(rule.includes('font: inherit;'))
    assert.ok(rule.includes('font-size: var(--svb-tab-title-font-size, 13px);'))
  })
})

describe('tab title font size - options', () => {
  it('exports the list of available sizes', () => {
    assert.ok(Array.isArray(TAB_TITLE_FONT_SIZES))
  })

  it('offers 20, 22 and 24 px alongside the smaller sizes', () => {
    assert.ok(Array.isArray(TAB_TITLE_FONT_SIZES))
    assert.ok([20, 22, 24].every(size => TAB_TITLE_FONT_SIZES.includes(size)))
  })

  it('keeps the 13 px default in the options', () => {
    assert.ok(Array.isArray(TAB_TITLE_FONT_SIZES))
    assert.ok(TAB_TITLE_FONT_SIZES.includes(13))
  })
})

describe('settings input coercion', () => {
  it('exports a normalizer for settings fields', () => {
    assert.equal(typeof normalizeSettingValue, 'function')
  })

  it('coerces tabTitleFontSize from a select string to a number', () => {
    assert.strictEqual(normalizeSettingValue('tabTitleFontSize', '14'), 14)
  })

  it('coerces autoCloseTabsDays from a select string to a number', () => {
    assert.strictEqual(normalizeSettingValue('autoCloseTabsDays', '7'), 7)
  })

  it('leaves string settings unchanged', () => {
    assert.strictEqual(normalizeSettingValue('newTabPlacement', 'top'), 'top')
  })
})
