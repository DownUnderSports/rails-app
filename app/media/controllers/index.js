import { AppDrawerController } from 'controllers/app_drawer_controller'
import { ClipboardController } from 'controllers/clipboard_controller'
import { ListController } from 'controllers/list_controller'
import { TextFieldController } from 'controllers/text_field_controller'
import { TopBarController } from 'controllers/top_bar_controller'

export const registerControllers = (StimulusApplication) => {
  StimulusApplication.register('app-drawer', AppDrawerController)
  StimulusApplication.register('clipboard', ClipboardController)
  StimulusApplication.register('list', ListController)
  StimulusApplication.register('text-field', TextFieldController)
  StimulusApplication.register('top-bar', TopBarController)
}
