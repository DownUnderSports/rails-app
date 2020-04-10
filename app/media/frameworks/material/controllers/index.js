import { AppDrawerController } from 'frameworks/material/controllers/app_drawer_controller'
import { CheckboxController } from 'frameworks/material/controllers/checkbox_controller'
import { ListController } from 'frameworks/material/controllers/list_controller'
import { TextFieldController } from 'frameworks/material/controllers/text_field_controller'
import { TopBarController } from 'frameworks/material/controllers/top_bar_controller'

export const registerControllers = (StimulusApplication) => {
  StimulusApplication.register('app-drawer', AppDrawerController)
  StimulusApplication.register('checkbox', CheckboxController)
  StimulusApplication.register('list', ListController)
  StimulusApplication.register('text-field', TextFieldController)
  StimulusApplication.register('top-bar', TopBarController)
}
