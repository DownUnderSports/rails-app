import { ClipboardController } from 'controllers/clipboard_controller'
import { registerControllers as registerMaterialControllers } from 'frameworks/material/controllers'

export const registerControllers = (StimulusApplication) => {
  StimulusApplication.register('clipboard', ClipboardController)
  registerMaterialControllers(StimulusApplication)
}
