#include <Geode/Geode.hpp>
#include <objc/runtime.h>
#include <UIKit/UIKit.h>
#include <imgui-cocos.hpp>

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