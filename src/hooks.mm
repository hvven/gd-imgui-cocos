#include <Geode/Geode.hpp>
#include <objc/runtime.h>
#include <UIKit/UIKit.h>
#include <imgui-cocos.hpp>

@interface EAGLView : UIView
@end

static IMP swapBuffersOIMP;
void swapBuffers(EAGLView* self, SEL sel) {
    static auto init = false;

    if (!init) {
        ImGuiCocos::get().setup();
        init = true;
    }

    if (ImGuiCocos::get().isInitialized())
        ImGuiCocos::get().drawFrame();

    reinterpret_cast<decltype(&swapBuffers)>(swapBuffersOIMP)(self, sel);
}

$execute {
    auto EAGLView = objc_getClass("EAGLView");
    auto swapBuffersMethod = class_getInstanceMethod(EAGLView, @selector(swapBuffers));
    swapBuffersOIMP = method_getImplementation(swapBuffersMethod);
    method_setImplementation(swapBuffersMethod, (IMP)&swapBuffers);
}

UITextField* input = nil;

@interface Input : NSObject<UITextFieldDelegate> @end
@implementation Input

+ (void)setup {
    dispatch_async(dispatch_get_main_queue(), ^{
        input = [UITextField.alloc init];
        input.hidden = YES;
        input.text = @"Text";
        input.autocorrectionType = UITextAutocorrectionTypeNo;
        input.delegate = [Input.alloc init];
    });
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    auto &io = ImGui::GetIO();

    if ([string isEqualToString:@"\n"]) {
        io.AddKeyEvent(ImGuiKey_Enter, true);
        io.AddKeyEvent(ImGuiKey_Enter, false);

        ImGuiCocos::closeKeyboard();
    } else if (string.length > 0) {
        unichar ch = [string characterAtIndex:0];
        io.AddInputCharacter(ch);
    } else {
        io.AddKeyEvent(ImGuiKey_Backspace, true);
        io.AddKeyEvent(ImGuiKey_Backspace, false);
    }

    return NO;
}

@end

void ImGuiCocos::openKeyboard() {
    if (input) {
        UIView *view = UIApplication.sharedApplication.delegate.window.rootViewController.view;
        [view addSubview:input];
        [input becomeFirstResponder];
    }
}

void ImGuiCocos::closeKeyboard() {
    if (input) {
        [input resignFirstResponder];
        [input removeFromSuperview];
    }
}

$execute {
    [Input setup];
}