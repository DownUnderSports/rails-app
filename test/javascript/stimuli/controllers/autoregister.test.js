import { AppDrawerController   } from "stimuli/controllers/app-drawer-controller"
import { CheckboxController    } from "stimuli/controllers/checkbox-controller"
import { ClipboardController   } from "stimuli/controllers/clipboard-controller"
import { DropzoneController    } from "stimuli/controllers/dropzone-controller"
import { DynamicLinkController } from "stimuli/controllers/dynamic-link-controller"
import { ListController        } from "stimuli/controllers/list-controller"
import { TextFieldController   } from "stimuli/controllers/text-field-controller"
import { TimeSyncController    } from "stimuli/controllers/time-sync-controller"
import { TopBarController      } from "stimuli/controllers/top-bar-controller"
import { YoutubeController     } from "stimuli/controllers/youtube-controller"

jest.mock("stimuli/controllers/app-drawer-controller",   () => ({ AppDrawerController: { load: jest.fn() } }))
jest.mock("stimuli/controllers/checkbox-controller",     () => ({ CheckboxController: { load: jest.fn() } }))
jest.mock("stimuli/controllers/clipboard-controller",    () => ({ ClipboardController: { load: jest.fn() } }))
jest.mock("stimuli/controllers/dropzone-controller",     () => ({ DropzoneController: { load: jest.fn() } }))
jest.mock("stimuli/controllers/dynamic-link-controller", () => ({ DynamicLinkController: { load: jest.fn() } }))
jest.mock("stimuli/controllers/list-controller",         () => ({ ListController: { load: jest.fn() } }))
jest.mock("stimuli/controllers/text-field-controller",   () => ({ TextFieldController: { load: jest.fn() } }))
jest.mock("stimuli/controllers/time-sync-controller",    () => ({ TimeSyncController: { load: jest.fn() } }))
jest.mock("stimuli/controllers/top-bar-controller",      () => ({ TopBarController: { load: jest.fn() } }))
jest.mock("stimuli/controllers/youtube-controller",      () => ({ YoutubeController: { load: jest.fn() } }))

describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("autoregister", () => {
      it("loads default controllers on first eval", async () => {
        expect(AppDrawerController.load).not.toHaveBeenCalled()
        expect(CheckboxController.load).not.toHaveBeenCalled()
        expect(ClipboardController.load).not.toHaveBeenCalled()
        expect(DropzoneController.load).not.toHaveBeenCalled()
        expect(DynamicLinkController.load).not.toHaveBeenCalled()
        expect(ListController.load).not.toHaveBeenCalled()
        expect(TextFieldController.load).not.toHaveBeenCalled()
        expect(TimeSyncController.load).not.toHaveBeenCalled()
        expect(TopBarController.load).not.toHaveBeenCalled()
        expect(YoutubeController.load).not.toHaveBeenCalled()

        await import("stimuli/controllers/autoregister")

        expect(AppDrawerController.load).toHaveBeenCalledTimes(1)
        expect(CheckboxController.load).toHaveBeenCalledTimes(1)
        expect(ClipboardController.load).toHaveBeenCalledTimes(1)
        expect(DropzoneController.load).toHaveBeenCalledTimes(1)
        expect(DynamicLinkController.load).toHaveBeenCalledTimes(1)
        expect(ListController.load).toHaveBeenCalledTimes(1)
        expect(TextFieldController.load).toHaveBeenCalledTimes(1)
        expect(TimeSyncController.load).toHaveBeenCalledTimes(1)
        expect(TopBarController.load).toHaveBeenCalledTimes(1)
        expect(YoutubeController.load).toHaveBeenCalledTimes(1)

        await import("stimuli/controllers/autoregister")

        expect(AppDrawerController.load).toHaveBeenCalledTimes(1)
        expect(CheckboxController.load).toHaveBeenCalledTimes(1)
        expect(ClipboardController.load).toHaveBeenCalledTimes(1)
        expect(DropzoneController.load).toHaveBeenCalledTimes(1)
        expect(DynamicLinkController.load).toHaveBeenCalledTimes(1)
        expect(ListController.load).toHaveBeenCalledTimes(1)
        expect(TextFieldController.load).toHaveBeenCalledTimes(1)
        expect(TimeSyncController.load).toHaveBeenCalledTimes(1)
        expect(TopBarController.load).toHaveBeenCalledTimes(1)
        expect(YoutubeController.load).toHaveBeenCalledTimes(1)
      })
    })
  })
})
