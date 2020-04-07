import {
  MDCCheckbox,
  MDCChipSet,
  MDCDialog,
  MDCFormField,
  MDCIconButtonToggle,
  MDCLinearProgress,
  MDCMenu,
  MDCRadio,
  MDCRipple,
  MDCSelect,
  MDCSlider,
  MDCSnackbar,
  MDCSwitch,
  MDCTabBar,
  MDCTextFieldHelperText,
  MDCDataTable
} from 'designs/material/components';

// Import my theme variables
import themeName from 'designs/material/theme';

//
// Instantiate all components in the main content
//

// Button
const buttonEls = Array.from(document.querySelectorAll('.mdc-button'));
buttonEls.forEach((el) => new MDCRipple(el));

// Icon button toggle
const iconToggleEls = Array.from(document.querySelectorAll('#icon-toggle-button'));
iconToggleEls.forEach(el => {
  const iconToggle = new MDCIconButtonToggle(el)
  iconToggle.unbounded = true;
});

// Card
const cardPrimaryActionEls = Array.from(document.querySelectorAll('.mdc-card__primary-action'));
cardPrimaryActionEls.forEach((el) => new MDCRipple(el));

// Chips
const chipSetEls = Array.from(document.querySelectorAll('.mdc-chip-set'));
chipSetEls.forEach((el) => new MDCChipSet(el));

// Text field

const helperTextEls = Array.from(document.querySelectorAll('.mdc-text-field-helper-text'));
helperTextEls.forEach((el) => new MDCTextFieldHelperText(el));

// Linear progress
const linearProgressEls = Array.from(document.querySelectorAll('.mdc-linear-progress'));
linearProgressEls.forEach(el => {
  const linearProgress = new MDCLinearProgress(el)
  linearProgress.progress = 0.5;
});

// FAB
const fabEls = Array.from(document.querySelectorAll('.mdc-fab'));
fabEls.forEach((el) => new MDCRipple(el));

// Checkbox
const checkboxEls = Array.from(document.querySelectorAll('.mdc-checkbox'));
checkboxEls.forEach((el) => {
  let checkbox = new MDCCheckbox(el);
  if (el.classList.contains('indeterminate-checkbox')) {
    checkbox.indeterminate = true;
  }
});

// Radio
const radioEls = Array.from(document.querySelectorAll('.mdc-radio'));
radioEls.forEach((el) => new MDCRadio(el));

// Switch
const switchEls = Array.from(document.querySelectorAll('.mdc-switch'));
switchEls.forEach((el) => new MDCSwitch(el));

// Select
const selectEls = Array.from(document.querySelectorAll('.mdc-select'));
selectEls.forEach((el) => new MDCSelect(el));

// Snackbar
const snackbarEls = Array.from(document.querySelectorAll('.mdc-snackbar'));
snackbarEls.forEach(el => new MDCSnackbar(el));

// Dialog
const dialogEls = Array.from(document.querySelectorAll('.mdc-dialog'));
dialogEls.forEach(el => new MDCDialog(el));

// Slider
const sliderEls = Array.from(document.querySelectorAll('.mdc-slider'));
sliderEls.forEach(el => {
  const slider = new MDCSlider(el)
  slider.value = 5;
});

// Menu
const menuEls = Array.from(document.querySelectorAll('.mdc-menu'));
menuEls.forEach(el => {
  const menu = new MDCMenu(el)
  menu.open = true;
  // Focus first component when menu is done opening if not in an iframe
  if (window.top === window) {
    el.addEventListener('MDCMenuSurface:opened', () => document.querySelector('.mdc-button').focus());
  }
});



// Tabs
const tabBarEls = Array.from(document.querySelectorAll('.mdc-tab-bar'));
tabBarEls.forEach(el => new MDCTabBar(el));

// Data Table
const dataTableEls = Array.from(document.querySelectorAll('.mdc-data-table'));
dataTableEls.forEach(el => new MDCDataTable(el));
