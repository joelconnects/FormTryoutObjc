//
//  ViewController.m
//  TextFieldNonsense
//
//  Created by Joel Bell on 3/25/16.
//  Copyright © 2016 Joel Bell. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+Extensions.h"
#import "GradientView.h"

// Local constants
static NSString * const kEmailPlaceholder = @"Email";
static NSString * const kEmailConfirmPlaceholder = @"Confirm email";
static NSString * const kPasswordPlaceholder = @"Password";
static NSString * const kPasswordConfirmPlaceholder = @"Confirm password";
static NSString * const kEmailNotValid = @"Enter valid email";
static NSString * const kEmailDoesNotMatch = @"Email does not match";
static NSString * const kPasswordNotValid = @"Enter valid password";
static NSString * const kPasswordDoesNotMatch = @"Password does not match";
static NSString * const kHiddenPlaceholder = @"Hidden placeholder";

// Form progress enum
typedef enum {
    SetUpStage = 0,
    StageOne = 1,
    StageTwo = 2,
    StageThree = 3,
    StageFour = 4,
    StageFive = 5,
    OpeningAnimationStage = 6,
    TransitionAnimationStage = 7
}FormProgress;

// Background view state enum
typedef enum {
    BackgroundEdit,
    BackgroundPrompt,
    BackgroundError
}BackgroundViewState;

@interface ViewController ()<UITextFieldDelegate>

// TextField properties
@property (strong, nonatomic) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *emailConfirm;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirm;
@property (strong, nonatomic) UITextField *hiddenTextField;

// Button properties
@property (weak, nonatomic) IBOutlet UIView *submitButtonView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

// Background view properties
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) NSArray *backgroundViews;
@property (weak, nonatomic) IBOutlet UIView *backgroundTopView;
@property (weak, nonatomic) IBOutlet UIView *backgroundBottomView;
@property (strong, nonatomic) UIView *currentBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *backgroundBottomBordersView;
@property (nonatomic, strong) GradientView *gradientViewTop;
@property (nonatomic, strong) GradientView *gradientViewBottom;
@property (weak, nonatomic) IBOutlet UIView *backgroundFrameView;
@property (strong, nonatomic) UIView *textFieldFrameView;

// Form progress property
@property (nonatomic, assign) FormProgress progress;

// Constraint properties
@property (nonatomic, strong) NSLayoutConstraint *textFieldFrameTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *gradientViewHeightConstraintForBackgroundTopView;
@property (nonatomic, strong) NSLayoutConstraint *gradientViewHeightConstraintForBackgroundBtmView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitButtonTopConstraint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add top/bottom background views to backgroundViews property array
    self.backgroundViews = @[self.backgroundTopView,self.backgroundBottomView];
    
    // Set current background view to background top view
    self.currentBackgroundView = self.backgroundTopView;
    
    // Set background views alpha to zero
    self.currentBackgroundView.alpha = 0;
    self.backgroundBottomView.alpha = 0;
    
    // Set background image of backgroundImageView
    self.backgroundImageView.image = [UIImage imageNamed:@"signUpBackground"];
    self.backgroundImageView.alpha = 0;
    
    // Set up hidden text field
    self.hiddenTextField = [[UITextField alloc] init];
    self.hiddenTextField.hidden = YES;
    self.hiddenTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.hiddenTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    self.hiddenTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.hiddenTextField.keyboardType = UIKeyboardTypeASCIICapable;
    
    // Add hidden text field to main view
    [self.view addSubview:self.hiddenTextField];
    
    // Set placeholder text for text fields
    self.email.placeholder = kEmailPlaceholder;
    self.emailConfirm.placeholder = kEmailConfirmPlaceholder;
    self.password.placeholder = kPasswordPlaceholder;
    self.passwordConfirm.placeholder = kPasswordConfirmPlaceholder;
    self.hiddenTextField.placeholder = kHiddenPlaceholder;
    
    // Add text fields to textFields property array
    self.textFields = @[self.email,self.emailConfirm,self.password,self.passwordConfirm,self.hiddenTextField];
    
    // Loop through textFields property array to set up text fields
    for (UITextField *textField in self.textFields)
    {
        // Set delegate for text field
        textField.delegate = self;
        
        // Add target action for text field
        [textField addTarget:self action:@selector(controlEventEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        
        // Set font & color properties for text field
        textField.tintColor = [UIColor clearColor];
        [textField setFont:[UIFont systemFontOfSize:20.0]];
        textField.textColor = [UIColor whiteColor];
        textField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        textField.alpha = 0;
        
        // Set border layer properties (necessary for hiding border)
        textField.borderStyle = UITextBorderStyleNone;
        textField.layer.cornerRadius = 0.0;
        textField.layer.masksToBounds = YES;
        textField.layer.borderColor=[[UIColor whiteColor]CGColor];
        textField.layer.borderWidth = 0.0;
        
        // Define and add placeholder attributes to dictionary
        NSMutableDictionary *attributesDictionary = [NSMutableDictionary dictionary];
        [attributesDictionary setObject:[UIFont systemFontOfSize:20.0] forKey:NSFontAttributeName];
        [attributesDictionary setObject:[UIColor placeholderPurple] forKey:NSForegroundColorAttributeName];
        
        // Update attributed placeholder with text and attributes from dictionary
        NSString *placeholder = textField.placeholder;
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:attributesDictionary];
        
        // Create and add view to act as left margin in text field
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, textField.frame.size.height)];
        textField.leftView = leftView;
        textField.leftViewMode = UITextFieldViewModeAlways;
        
    }
    
    // Set secureTextEntry to YES for password text fields
    self.password.secureTextEntry = YES;
    self.passwordConfirm.secureTextEntry = YES;
    
    // Set submitDisabled button alpha to zero
    self.submitButton.alpha = 0;
    
    // Set title color of submit disabled
    [self.submitButton setTitleColor:[UIColor placeholderPurple] forState:UIControlStateNormal];
    
    // Set starting stage
    self.progress = SetUpStage;
    
    // Add keyboard notification observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    
    NSLog(@"view did load completed");
  
}

-(void)viewDidLayoutSubviews {
    NSLog(@"view did layout subviews");
    
    if (self.progress == SetUpStage) {
        NSLog(@"viewDidLayoutSubview - SetUpStage");
        
        self.progress = OpeningAnimationStage;
        
        for (UITextField *textField in self.textFields) {
            for (UIGestureRecognizer *gesture in textField.gestureRecognizers) {
                NSLog(@"gesture: %@",gesture);
            }
        }
        
        CGRect emailTextFieldFrame = [self.view convertRect:self.email.frame fromView:self.email.superview];
        
        CGFloat topGradientHeight = emailTextFieldFrame.origin.y + (emailTextFieldFrame.size.height / 2);
        
        // Loop through backgroundViews property array
        for (UIView *view in self.backgroundViews) {
            
            // Add top gradient to view
            GradientView *top = [[GradientView alloc] init];
        
            // Add bottom gradient to view
            GradientView *bottom = [[GradientView alloc] init];
            
            // Add gradients as subviews to view
            [view addSubview:top];
            [view addSubview:bottom];
            
            // Set gradients for top and bottom views
            [self setGradientsForBackgroundView:view forState:BackgroundEdit];
            
            top.translatesAutoresizingMaskIntoConstraints = NO;
            bottom.translatesAutoresizingMaskIntoConstraints = NO;
            
            [top.leadingAnchor constraintEqualToAnchor:view.leadingAnchor].active = YES;
            [top.trailingAnchor constraintEqualToAnchor:view.trailingAnchor].active = YES;
            [top.topAnchor constraintEqualToAnchor:view.topAnchor].active = YES;
            
            [bottom.leadingAnchor constraintEqualToAnchor:view.leadingAnchor].active = YES;
            [bottom.trailingAnchor constraintEqualToAnchor:view.trailingAnchor].active = YES;
            [bottom.topAnchor constraintEqualToAnchor:top.bottomAnchor].active = YES;
            [bottom.bottomAnchor constraintEqualToAnchor:view.bottomAnchor].active = YES;
            
            if ([view isEqual:self.backgroundTopView]) {
                
                self.gradientViewHeightConstraintForBackgroundTopView = [top.heightAnchor constraintEqualToConstant:topGradientHeight];
                self.gradientViewHeightConstraintForBackgroundTopView.active = YES;
                
            } else {
                
                self.gradientViewHeightConstraintForBackgroundBtmView = [top.heightAnchor constraintEqualToConstant:topGradientHeight];
                self.gradientViewHeightConstraintForBackgroundBtmView.active = YES;
                
            }
            
            
            
        }
        
        
    }
    
    NSLog(@"finished viewDidLayoutSubviews");
}

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"view did appear");
    
    // Make email text field first responder
    [self.email becomeFirstResponder];
    
    // First call for animation depenency
    if (self.progress == OpeningAnimationStage) {
        
        // Animate background for email text field
        [self animateBackgroundViewsForTextField:self.email];
    }
}

-(void)keyboardDidHide {
    NSLog(@"keyboard did hide");
    
    // Animate and enable submit button
//    if ([self validateAllFields]) {
//        [self animateSubmitButtonEnabled];
//    }
//    
}

-(void)keyboardDidShow {
    NSLog(@"keyboard did show");
    
    // First call for animation dependency
    if (self.progress == OpeningAnimationStage) {
        
        // Set background frame view and background bottom borders view alpha to zero
        self.backgroundFrameView.alpha = 0;
        self.backgroundBottomBordersView.alpha = 0;
        
        // Loop through all text fields to build path views
        for (UITextField *textField in self.textFields) {
            
            // Create empty view for path
            UIView *textFieldBackgroundView = [[UIView alloc] init];
            
            // Create path to run along bottom of each text field
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, textField.bounds.size.height + 1)];
            [path addLineToPoint:CGPointMake(textField.bounds.size.width, textField.bounds.size.height + 1)];
            
            // Create and add path to shape layer of empty view
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = [path CGPath];
            shapeLayer.strokeColor = [[UIColor deepPinkPurple] colorWithAlphaComponent:0.05].CGColor;
            shapeLayer.lineWidth = 2.0;
            shapeLayer.fillColor = [UIColor clearColor].CGColor;
            [textFieldBackgroundView.layer addSublayer:shapeLayer];
            
            // Add empty view with path to backgroundBottomBordersView
            [self.backgroundBottomBordersView addSubview:textFieldBackgroundView];
            
            // Apply constraints to empty view
            textFieldBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
            [textFieldBackgroundView.topAnchor constraintEqualToAnchor:textField.topAnchor].active = YES;
            [textFieldBackgroundView.bottomAnchor constraintEqualToAnchor:textField.bottomAnchor].active = YES;
            [textFieldBackgroundView.leadingAnchor constraintEqualToAnchor:textField.leadingAnchor].active = YES;
            [textFieldBackgroundView.trailingAnchor constraintEqualToAnchor:textField.leadingAnchor].active = YES;
            
        }
        
        // Create textFieldFrameView to move with user as form is completed
        self.textFieldFrameView = [[UIView alloc] init];
        
        // Create border for textFieldFrameView
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        CGRect borderRect = CGRectMake(0, 0, self.email.bounds.size.width, self.email.bounds.size.height);
        borderLayer.path = [UIBezierPath bezierPathWithRect:borderRect].CGPath;
        borderLayer.strokeColor = [[UIColor whiteColor] CGColor];
        borderLayer.lineWidth = 2;
        [self.textFieldFrameView.layer addSublayer:borderLayer];
        
        // Add textFieldFrameView to backgroundFrameView
        [self.backgroundFrameView addSubview:self.textFieldFrameView];
        
        // Apply constraints to textFieldFrameView
        self.textFieldFrameView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.textFieldFrameView.leftAnchor constraintEqualToAnchor:self.email.leftAnchor].active = YES;
        [self.textFieldFrameView.widthAnchor constraintEqualToAnchor:self.email.widthAnchor].active = YES;
        [self.textFieldFrameView.heightAnchor constraintEqualToAnchor:self.email.heightAnchor].active = YES;
        self.textFieldFrameTopConstraint = [self.textFieldFrameView.topAnchor constraintEqualToAnchor:self.email.topAnchor];
        self.textFieldFrameTopConstraint.active = YES;
        
        // Animate all text fields and related views from zero to one
        [UIView animateWithDuration:0.6 animations:^{
            self.email.alpha = 1.0;
            self.emailConfirm.alpha = 1.0;
            self.password.alpha = 1.0;
            self.passwordConfirm.alpha = 1.0;
            self.submitButton.alpha = 1.0;
            self.backgroundBottomBordersView.alpha = 1.0;
            self.backgroundFrameView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
            // Set progress to stage one
            self.progress = StageOne;
            
            // Set email tint color from clear to white
            self.email.tintColor = [UIColor whiteColor];
        }];
    }
}

- (IBAction)submitButtonPressed:(id)sender {
    NSLog(@"submit pressed");
    
    if ([self validateAllFields]) {
        // submit form information
    } else {
        UITextField *textField;
        
        switch (self.progress) {
            case StageOne:
                textField = self.email;
                break;
            case StageTwo:
                textField = self.emailConfirm;
                break;
            case StageThree:
                textField = self.password;
                break;
            case StageFour:
                textField = self.passwordConfirm;
                break;
            default:
                break;
        }
        
        [self highlightBackgroundToPromptUser:textField];
    }
    
    
}

- (IBAction)submitEnabledAction:(id)sender {
    NSLog(@"submit enabled pressed");
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    NSLog(@"should begin editing, progress: %u", self.progress);
    
    if (self.progress == StageOne) {
        NSLog(@"if stage 1");
        return YES;
    }
    
    if (self.progress == StageTwo) {
        NSLog(@"if stage 2");
        if ([textField isEqual:self.password] || [textField isEqual:self.passwordConfirm]) {
            
            if (self.emailConfirm.text.length > 0) {
                [self highlightBackgroundForValidationError:self.emailConfirm placeholder:kEmailDoesNotMatch];
            } else {
                [self highlightBackgroundToPromptUser:self.emailConfirm];
                [self.emailConfirm becomeFirstResponder];
            }
            return NO;
        }

    }
    
    if (self.progress == StageThree) {
        NSLog(@"if stage 3");
        if ([textField isEqual:self.passwordConfirm]) {
            if (self.password.text.length > 0) {
                [self highlightBackgroundForValidationError:self.password placeholder:kPasswordNotValid];
            } else {
                [self highlightBackgroundToPromptUser:self.password];
                [self.email resignFirstResponder];
                [self.password becomeFirstResponder];
            }
            
            return NO;
        }
        
        
    }
    
    if (self.progress == StageFour) {
        if ([textField isEqual:self.password] || [textField isEqual:self.email]) {
            if (self.passwordConfirm.text.length > 0) {
                self.passwordConfirm.text = nil;
            }
        }
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    NSLog(@"textField did begin editing");
    if (self.progress != OpeningAnimationStage || self.progress != TransitionAnimationStage) {
        
        self.textFieldFrameView.alpha = 1;
        [self animateBackgroundViewsForTextField:textField];
        
    }
    
    
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSLog(@"should change characters in range");
    
    NSMutableString *currentString = [NSMutableString stringWithString:textField.text];
    if (string.length > 0) {
        NSLog(@"string length is greater than zero");
        [currentString replaceCharactersInRange:range withString:string];
    } else {
        NSLog(@"string length is zero");
        [currentString replaceCharactersInRange:range withString:@""];
    }
    
    if ([textField isEqual:self.email]) {
        NSLog(@"if self.email, change stages 1 & 2");
        if ([self validateEmail:currentString]) {
            NSLog(@"stage 2");
            self.progress = StageTwo;
        } else {
            NSLog(@"stage 1");
            self.progress = StageOne;
        }
    }
    
    if ([textField isEqual:self.password]) {
        NSLog(@"if self.password, change stages 3 & 4");
        if ([self validatePassword:currentString]) {
            NSLog(@"stage 4");
            self.progress = StageFour;
        } else {
            NSLog(@"stage 3");
            self.progress = StageThree;
        }
    }
    
    if (self.progress == StageOne) {
        if (self.emailConfirm.text.length > 0) {
            self.emailConfirm.text = nil;
            self.emailConfirm.textColor = [UIColor whiteColor];
            self.emailConfirm.userInteractionEnabled = YES;
        }
    }
    
    if (self.progress == StageThree) {
        if (self.passwordConfirm.text.length > 0) {
            self.passwordConfirm.text = nil;
            self.passwordConfirm.textColor = [UIColor whiteColor];
            self.passwordConfirm.userInteractionEnabled = YES;
        }
    }

    return YES;
    
    

}


-(void)controlEventEditingChanged:(UITextField *)textField {
    NSLog(@"control event editing changed - stage: %u",self.progress);
    
    
    
    if (self.progress == StageTwo) {
        NSLog(@"if stage 2");
        if ([self validateEmailConfirm:self.emailConfirm.text]) {
            self.emailConfirm.textColor = [UIColor placeholderPurple];
            
            if ([self validatePasswordConfirm:self.passwordConfirm.text]) {
                
                self.progress = StageFive;
                [self.emailConfirm resignFirstResponder];
//                [self highlightBackgroundOfSubmitButton];
                
            } else if ([self validatePassword:self.password.text]) {
                self.progress = StageFour;
                [self.emailConfirm resignFirstResponder];
                [self.passwordConfirm becomeFirstResponder];
                [self highlightBackgroundToPromptUser:self.passwordConfirm];
                
            } else {
                self.progress = StageThree;
                [self.emailConfirm resignFirstResponder];
                [self.password becomeFirstResponder];
//                [self highlightBackgroundToPromptUser:self.password];
            }
        }

    }
    
    if (self.progress == StageFour) {
        NSLog(@"if stage 4");
        if ([self validatePasswordConfirm:self.passwordConfirm.text]) {
            self.passwordConfirm.textColor = [UIColor placeholderPurple];
            self.progress = StageFive;
            [self.passwordConfirm resignFirstResponder];
            
    
        }
        
    }
    
    if (![self validateAllFields]) {

        [self animateSubmitButtonDisabled];

    }
    
}



- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    
    NSLog(@"should end editing. stage: %u",self.progress);
    
    // check email text for validity
    if (self.progress == StageOne) {
        NSLog(@"if stage 1");
        
        BOOL valid = YES;
        
        valid = [self validateEmail:textField.text];
        if (!valid) {
            
            if (self.email.text.length == 0) {
                NSLog(@"text length is zero. prompt user.");
                [self highlightBackgroundToPromptUser:textField];
            } else {
                NSLog(@"text length is greater than zero. highlight error");
//                textField.text = nil;
                [self highlightBackgroundForValidationError:textField placeholder:kEmailNotValid];
            }
            
            
        }
        return valid;
    }
    
    return YES;

}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSLog(@"did end editing. stage: %u",self.progress);
    
    if (self.progress == StageTwo) {
        NSLog(@"if stage 2");
        if ([textField isEqual:self.emailConfirm]) {
            if (self.emailConfirm.text.length > 0) {
                self.emailConfirm.text = nil;
            }
        }
    }
    
    if (self.progress == StageThree) {
        NSLog(@"if stage 3");
        if ([textField isEqual:self.password]) {
            NSLog(@"if self.email");
            if (self.password.text.length > 0) {
                self.password.text = nil;
            }
        }
        
        
    }
    
    // lock email confirm
    if ([textField isEqual:self.emailConfirm]) {
        if ([self validateEmailConfirm:self.emailConfirm.text]) {
            self.emailConfirm.userInteractionEnabled = NO;
        }
    }
    
    if ([textField isEqual:self.passwordConfirm]) {
        if ([self validatePasswordConfirm:self.passwordConfirm.text]) {
            self.passwordConfirm.userInteractionEnabled = NO;
        }
    }
    
//    textField.layer.borderWidth = 0.0;
    
    textField.tintColor = [UIColor clearColor];
    
    if ([self validateAllFields]) {
        [self animateSubmitButtonEnabled];
    }
    
}




- (BOOL)validateEmail:(NSString *)email
{
    if (email.length < 2) {
        return NO;
    }
//    if ([email length] < 3){ return NO;}
//    if ([email rangeOfString:@"@"].location == NSNotFound){return NO;}
//    
//    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
//    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
//    NSUInteger regExMatches = [regEx numberOfMatchesInString:email options:0 range:NSMakeRange(0, [email length])];
//    
//    if (regExMatches == 0)
//    {
//        return NO;
//    }
    
    return YES;
}


- (BOOL)validateEmailConfirm:(NSString *)emailConfirm {
    
    if ([self.email.text isEqualToString:emailConfirm] && self.email.text.length > 0) {
        return YES;
    }
    return NO;
    
}

- (BOOL)validatePassword:(NSString *)password
{

    if (password.length < 2) {
        return NO;
    }
//    NSCharacterSet *upperCaseChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLKMNOPQRSTUVWXYZ"];
//    NSCharacterSet *lowerCaseChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];
//    
//    if ( [password length]<6 || [password length]>20 )
//        return NO;  // too long or too short
//    NSRange rang;
//    rang = [password rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
//    if ( !rang.length )
//        return NO;  // no letter
//    rang = [password rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
//    if ( !rang.length )
//        return NO;  // no number;
//    rang = [password rangeOfCharacterFromSet:upperCaseChars];
//    if ( !rang.length )
//        return NO;  // no uppercase letter;
//    rang = [password rangeOfCharacterFromSet:lowerCaseChars];
//    if ( !rang.length )
//        return NO;  // no lowerCase Chars;
    
    return YES;

}

- (BOOL)validatePasswordConfirm:(NSString *)passwordConfirm {
    
    if ([self.password.text isEqualToString:passwordConfirm] && self.password.text.length > 0) {
        return YES;
    }
    return NO;
    
}

-(BOOL)validateAllFields {
    
    if ([self validateEmail:self.email.text] &&
        [self validateEmailConfirm:self.emailConfirm.text] &&
        [self validatePassword:self.password.text] &&
        [self validatePasswordConfirm:self.passwordConfirm.text]) {
        return YES;
    }
    return NO;
    
}

-(void)setGradientsForBackgroundView:(UIView *)view forState:(BackgroundViewState)state {
        
    GradientView *top = view.subviews[0];
    GradientView *bottom = view.subviews[1];
    
    switch (state) {
        case BackgroundEdit:
            top.layer.colors = @[ (id)[UIColor whiteColor].CGColor, (id)[UIColor purpleColor].CGColor ];
            bottom.layer.colors = @[ (id)[UIColor purpleColor].CGColor, (id)[UIColor whiteColor].CGColor ];
            break;
        case BackgroundPrompt:
            top.layer.colors = @[ (id)[UIColor whiteColor].CGColor, (id)[UIColor blackColor].CGColor ];
            bottom.layer.colors = @[ (id)[UIColor blackColor].CGColor, (id)[UIColor whiteColor].CGColor ];
            break;
        case BackgroundError:
            top.layer.colors = @[ (id)[UIColor whiteColor].CGColor, (id)[UIColor redColor].CGColor ];
            bottom.layer.colors = @[ (id)[UIColor redColor].CGColor, (id)[UIColor whiteColor].CGColor ];
            break;
            
        default:
            break;
        
    }
    
}

-(void)updateGradientConstraintsWithConstant:(CGFloat)constant {
    self.gradientViewHeightConstraintForBackgroundTopView.constant = constant;
    self.gradientViewHeightConstraintForBackgroundBtmView.constant = constant;
}

-(void)animateBackgroundViewsForTextField:(UITextField *)textField {
    
    CGRect textFieldFrame = [self.view convertRect:textField.frame fromView:textField.superview];
    CGRect emailTextFieldFrame = [self.view convertRect:self.email.frame fromView:self.email.superview];
    
    CGFloat textFieldHeight = textField.frame.size.height;
    
    CGFloat topGradientHeightConstant = textFieldFrame.origin.y + (textFieldHeight / 2);
    
    if (self.progress == OpeningAnimationStage) {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.backgroundImageView.alpha = 1.0;
            self.currentBackgroundView.alpha = 0.5;
            
        } completion:nil];
        
    } else {
        
        CGFloat duration = 0.4;
        
        if ([textField isEqual:self.password]) {
            duration = duration * 1.3;
        }
        
        CGFloat constant = textFieldFrame.origin.y - emailTextFieldFrame.origin.y;
        
        [self.textFieldFrameView layoutIfNeeded];
        
        NSUInteger viewIndex = [[self.view subviews] indexOfObject:self.backgroundFrameView];
        [self.view bringSubviewToFront:self.backgroundFrameView];
        
        [UIView animateWithDuration:duration animations:^{
            
            self.textFieldFrameTopConstraint.constant = constant;
            [self updateGradientConstraintsWithConstant:topGradientHeightConstant];
            [self.currentBackgroundView layoutIfNeeded];
            [self.backgroundFrameView layoutIfNeeded];

            
        } completion:^(BOOL finished) {
            
            [self.view insertSubview:self.backgroundFrameView atIndex:viewIndex];
            textField.tintColor = [UIColor whiteColor];
            
            
            
        }];
        
        
    }
    
    
}


-(void)highlightBackgroundForValidationError:(UITextField *)textField placeholder:(NSString *)placeholderText {
    
    FormProgress currentProgress = self.progress;
    self.progress = TransitionAnimationStage;
    
    NSString *text = textField.text;
    textField.text = nil;
    
    for (UITextField *aTextField in self.textFields) {
        if (![aTextField isEqual:self.hiddenTextField]) {
            aTextField.userInteractionEnabled = NO;
        }
    }
    
    if ([textField isEqual:self.email] || [textField isEqual:self.emailConfirm]) {
        self.hiddenTextField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    [self.hiddenTextField becomeFirstResponder];
    
    UIView *oldBackgroundView = self.currentBackgroundView;
    UIView *newBackgroundView;
    
    if ([oldBackgroundView isEqual:self.backgroundTopView]) {
        newBackgroundView = self.backgroundBottomView;
    } else {
        newBackgroundView = self.backgroundTopView;
    }
    
//    NSArray *gradients = [self gradientsForBackgroundViewDependentOnTextField:textField forState:BackgroundError];
    
//    newBackgroundView.layer.sublayers = nil;
//    [newBackgroundView.layer insertSublayer:gradients[0] atIndex:0];
//    [newBackgroundView.layer insertSublayer:gradients[1] atIndex:1];
    
    NSMutableDictionary *attributesDictionary = [NSMutableDictionary dictionary];
    [attributesDictionary setObject:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];
    [attributesDictionary setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:attributesDictionary];
    
    [UIView animateKeyframesWithDuration:1.3 delay:0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.1 animations:^{
            
            textField.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
            oldBackgroundView.alpha = 0;
            newBackgroundView.alpha = 0.3;
            
        }];
        [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
            
            textField.backgroundColor = [UIColor whiteColor];
            oldBackgroundView.alpha = 0.3;
            newBackgroundView.alpha = 0;
            
        }];
    } completion:^(BOOL finished) {
        
        for (UITextField *aTextField in self.textFields) {
            if (![aTextField isEqual:self.hiddenTextField]) {
                aTextField.userInteractionEnabled = YES;
            }
        }
        [textField becomeFirstResponder];
        
        if ([textField isEqual:self.email] || [textField isEqual:self.emailConfirm]) {
            textField.text = text;
        } else {
            textField.text = nil;
        }
        
        self.hiddenTextField.keyboardType = UIKeyboardTypeASCIICapable;
        
        NSString *placeholderTextPostAnimation;
        
        if ([textField isEqual:self.email]) {
            placeholderTextPostAnimation = kEmailPlaceholder;
        }
        if ([textField isEqual:self.emailConfirm]) {
            placeholderTextPostAnimation = kEmailConfirmPlaceholder;
        }
        if ([textField isEqual:self.password]) {
            placeholderTextPostAnimation = kPasswordPlaceholder;
        }
        if ([textField isEqual:self.passwordConfirm]) {
            placeholderTextPostAnimation = kPasswordConfirmPlaceholder;
            
        }
        
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderTextPostAnimation attributes:@{NSForegroundColorAttributeName:[UIColor defaultAppleGray]}];
        
        self.progress = currentProgress;
        
    }];
    
}

-(void)highlightBackgroundToPromptUser:(UITextField *)textField {
    
    FormProgress currrentProgress = self.progress;
    self.progress = TransitionAnimationStage;
    
    [UIView animateKeyframesWithDuration:0.8 delay:0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.2 animations:^{
            
            textField.backgroundColor = [[UIColor deepPinkPurple] colorWithAlphaComponent:0.5];
    
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            
            textField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];

        }];
    } completion:^(BOOL finished) {
        
        self.progress = currrentProgress;
        
    }];
    
}



-(void)animateSubmitButtonEnabled {
    
    // Set submit button background view alpha to one
    // (necessary to reset from submit button disable animation)
    self.submitButtonView.alpha = 1;
    
    // Create views for background of submit button
    UIView *glowView = [[UIView alloc] init];
    UIView *bottomBorderView = [[UIView alloc] init];
    UIView *topView = [[UIView alloc] init];
    UIView *btmView = [[UIView alloc] init];
    
    // Set background colors of each background view
    glowView.backgroundColor = [UIColor placeholderPurple];
    bottomBorderView.backgroundColor = [UIColor shadowPurple];
    topView.backgroundColor = [UIColor deepPinkPurple];
    btmView.backgroundColor = [UIColor deepPinkPurple];
    
    // Set alpha for button background views to zero
    glowView.alpha = 0;
    bottomBorderView.alpha = 0;
    topView.alpha = 0;
    btmView.alpha = 0;
    
    // Add button background views to submitButtonView
    [self.submitButtonView addSubview:glowView];
    [self.submitButtonView addSubview:bottomBorderView];
    [self.submitButtonView addSubview:topView];
    [self.submitButtonView addSubview:btmView];
    
    // Turn off auto resizing of background views
    glowView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomBorderView.translatesAutoresizingMaskIntoConstraints = NO;
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    btmView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Set up constraints for bottomBorderView
    [bottomBorderView.topAnchor constraintEqualToAnchor:self.submitButtonView.topAnchor constant:self.submitButtonView.bounds.size.height/2].active = YES;
    [bottomBorderView.leadingAnchor constraintEqualToAnchor:self.submitButtonView.leadingAnchor].active = YES;
    [bottomBorderView.trailingAnchor constraintEqualToAnchor:self.submitButtonView.trailingAnchor].active = YES;
    
    // Create constraint variable for height of bottomBorderView
    NSLayoutConstraint *bottomBorderViewHeightConstraint = [bottomBorderView.heightAnchor constraintEqualToAnchor:self.submitButtonView.heightAnchor multiplier:0.0];
    bottomBorderViewHeightConstraint.active = YES;
    
    // Set up constraints for glowView
    [glowView.topAnchor constraintEqualToAnchor:self.submitButtonView.topAnchor].active = YES;;
    [glowView.leadingAnchor constraintEqualToAnchor:self.submitButtonView.leadingAnchor].active = YES;
    [glowView.trailingAnchor constraintEqualToAnchor:self.submitButtonView.trailingAnchor].active = YES;
    [glowView.bottomAnchor constraintEqualToAnchor:self.submitButtonView.bottomAnchor].active = YES;
    
    // Set up constraints for top view
    [topView.leadingAnchor constraintEqualToAnchor:self.submitButtonView.leadingAnchor].active = YES;
    [topView.trailingAnchor constraintEqualToAnchor:self.submitButtonView.trailingAnchor].active = YES;
    [topView.bottomAnchor constraintEqualToAnchor:bottomBorderView.topAnchor].active = YES;
    
    // Create constraint variable for height of top view
    NSLayoutConstraint *topViewHeightConstraint = [topView.heightAnchor constraintEqualToAnchor:self.submitButtonView.heightAnchor multiplier:0.0];
    topViewHeightConstraint.active = YES;
    
    // Set up constraints for bottom view
    [btmView.topAnchor constraintEqualToAnchor:self.submitButtonView.topAnchor constant:self.submitButtonView.bounds.size.height/2].active = YES;
    [btmView.leadingAnchor constraintEqualToAnchor:self.submitButtonView.leadingAnchor].active = YES;
    [btmView.trailingAnchor constraintEqualToAnchor:self.submitButtonView.trailingAnchor].active = YES;
    
    // Create constraint variable for height of bottom view
    NSLayoutConstraint *btmViewHeightConstraint = [btmView.heightAnchor constraintEqualToAnchor:self.submitButtonView.heightAnchor multiplier:0.0];
    btmViewHeightConstraint.active = YES;
    
    // Layout constraints for button background views
    [glowView layoutIfNeeded];
    [bottomBorderView layoutIfNeeded];
    [topView layoutIfNeeded];
    [btmView layoutIfNeeded];
    
    // Set up the "glow" of the glow view
    glowView.layer.cornerRadius = 5.0;
    glowView.layer.shadowColor = [UIColor deepPinkPurple].CGColor;
    glowView.layer.shadowOpacity = 0.8;
    glowView.layer.shadowRadius = 15;
    glowView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    
    // Create constant values for spring effect
    CGFloat greaterConstant = 10;
    CGFloat lesserConstant = 5;
    
    // Create padding value to reveal border in border view
    CGFloat borderPadding = 3;
    
    // Create height value from half the height of the submitButtonView
    CGFloat halfButtonViewHeight = self.submitButtonView.bounds.size.height / 2;
    
    
    // Animate button background views
    [UIView animateKeyframesWithDuration:0.8 delay:0.0 options:0 animations:^{
        // Add starting keyframe animation
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            
            // Fade in top, bottom, and border view
            topView.alpha = 1.0;
            btmView.alpha = 1.0;
            bottomBorderView.alpha  = 1.0;
            
            // Fade out textFieldFrameView
            self.textFieldFrameView.alpha = 0.0;
            
            // Update constant values of background views for animation
            topViewHeightConstraint.constant = halfButtonViewHeight + lesserConstant;
            btmViewHeightConstraint.constant = halfButtonViewHeight + greaterConstant;
            bottomBorderViewHeightConstraint.constant = halfButtonViewHeight + greaterConstant + borderPadding;
            
            // Update layout of submitButtonView to reflect
            // changes to background view constraint constants
            [self.submitButtonView layoutIfNeeded];
            
            // Update constant value for submitButtonTopConstraint
            self.submitButtonTopConstraint.constant = 6;
            
            // Update layout of submit button superview to reflect
            // changes to submit button constraint constant
            [[self.submitButton superview] layoutIfNeeded];
            
            [self addTopRoundedCorners:topView];
            
            
            
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            
            // Update button background view constraint constants for final position
            topViewHeightConstraint.constant = halfButtonViewHeight;
            btmViewHeightConstraint.constant = halfButtonViewHeight;
            bottomBorderViewHeightConstraint.constant = halfButtonViewHeight + borderPadding;
            
            // Update layout of submitButtonView to reflect
            // changes to background view constraint constants
            [self.submitButtonView layoutIfNeeded];
            
            // Update constant value of submitButtonTopConstraint for final position
            self.submitButtonTopConstraint.constant = 0;
            
            // Update layout of submit button superview to reflect
            // changes to submit button constraint constant
            [[self.submitButton superview] layoutIfNeeded];
            
            
            
        }];
        [UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
            
            // Adding bottom rounded corners here to make it work within the animation.
            // Could be refactored to avoid the odd placement
            [self addBottomRoundedCorners:bottomBorderView];
            
            // Fade down top view slightly for design effect
            topView.alpha = 0.95;
            
            // Fade in glow view
            glowView.alpha = 1.0;
            
        }];
    } completion:^(BOOL finished) {
        
        // Adding bottom rounded corners to both views within the animation
        // did not work. Could be refactored to avoid odd placement
        [self addBottomRoundedCorners:btmView];
        
    }];
    
}

-(void)addTopRoundedCorners:(UIView *)view {
 
    // Add top rounded corners to view
    UIBezierPath *maskPathTop;
    maskPathTop = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                        byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                              cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayerTop = [[CAShapeLayer alloc] init];
    maskLayerTop.frame = view.bounds;
    maskLayerTop.path = maskPathTop.CGPath;
    view.layer.mask = maskLayerTop;
    
}

-(void)addBottomRoundedCorners:(UIView *)view {
    
    // Add bottom rounded corners to view
    UIBezierPath *maskPathBorder;
    maskPathBorder = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                           byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                                 cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayerBorder = [[CAShapeLayer alloc] init];
    maskLayerBorder.frame = view.bounds;
    maskLayerBorder.path = maskPathBorder.CGPath;
    view.layer.mask = maskLayerBorder;
    
}

-(void)animateSubmitButtonDisabled {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.submitButtonView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        // Remove all subviews from the submit button view
        if ([self.submitButtonView subviews].count > 0) {
            NSArray *viewsForRemoval = [self.submitButtonView subviews];
            for (UIView *view in viewsForRemoval) {
                [view removeFromSuperview];
            }
        }
        
        
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {[super didReceiveMemoryWarning];}

@end
