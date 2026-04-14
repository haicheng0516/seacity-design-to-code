# iOS 项目规范（Objective-C）

Skill 在 iOS 项目上验证得最充分。以下是推荐的项目规范，Agent 会遵守这些规则写代码。

## 技术栈

- **语言**：Objective-C（或 Swift，本文档以 OC 为例）
- **布局**：Masonry（pod）
- **图片加载**：SDWebImage（pod）
- **HUD**：SVProgressHUD（pod）
- **Model**：YYModel（pod）
- **构建**：CocoaPods + `.xcworkspace`

## 目录结构

```
MyApp/
├── AppDelegate.h/.m
├── main.m
├── Info.plist
├── Assets.xcassets/
│   ├── app_logo.imageset/
│   └── ...
└── UI/
    ├── Base/
    │   ├── Controller/
    │   │   └── BaseViewController.h/.m
    │   └── View/
    │       └── UnifiedNavTitleView.h/.m
    ├── Common/
    │   ├── Utils/
    │   │   ├── Macros.h
    │   │   └── UIColors.h
    │   └── View/
    │       ├── SCGradientButton.h/.m
    │       ├── SCDarkTextField.h/.m
    │       ├── SCAlertPopupView.h/.m
    │       ├── SCAlertFactory.h/.m
    │       └── ...
    ├── Auth/
    │   ├── Controller/
    │   └── View/
    ├── Home/
    │   ├── Controller/
    │   ├── Model/
    │   └── View/
    ├── ...（其他模块同结构）
```

## 命名约定

### 文件命名
- Controller: `{ModuleName}{Feature}ViewController.h/.m`
- View: `{ModuleName}{Purpose}View.h/.m` 或 `{ModuleName}{Purpose}Cell.h/.m`
- 通用组件: `SC{ComponentName}.h/.m`（SC = 项目前缀 Seacity）

### 类名前缀
- 业务类: 模块名前缀（`HomeHeaderView`）
- 通用类: `SC` 前缀（`SCGradientButton`）

### 文件头注释
```objc
//
//  SCGradientButton.h
//  MyApp
//
```

## 代码风格

### 导入顺序
```objc
#import <UIKit/UIKit.h>        // 系统
#import <Masonry/Masonry.h>    // 第三方
#import "UIColors.h"           // 项目 Utils
#import "BaseViewController.h" // 项目基类
#import "HomeHeaderView.h"     // 相关业务
```

### 属性声明
```objc
@interface HomeHeaderView ()
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, copy) NSString *userName;    // copy for strings
@property (nonatomic, assign) NSInteger dayCount;  // assign for primitives
@end
```

### 约束写法
全部用 Masonry，不用原生 NSLayoutConstraint：
```objc
[self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(16);
    make.centerY.equalTo(self);
    make.width.height.mas_equalTo(64);
}];
```

### 颜色/字体不得硬编码
```objc
// ✅ 对
label.textColor = kTextPrimaryColor;
label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];

// ❌ 错
label.textColor = [UIColor whiteColor];
```

## View/Cell 分离规则（重要）

**所有 View 和 Cell 必须单独文件**，严禁定义在 ViewController 里。

```objc
// ❌ 严禁
@interface MainHomeViewController ()
@property (nonatomic, strong) UIView *checkInCard;  // 把卡片逻辑塞在 VC
@end

@implementation MainHomeViewController
- (void)setupCheckInCard {
    _checkInCard = [[UIView alloc] init];
    // ...200 行布局代码
}
@end
```

```objc
// ✅ 正确
// HomeCheckInCardView.h / .m — 独立文件
// MainHomeViewController 里只实例化使用
@implementation MainHomeViewController
- (void)setupUI {
    _checkInCard = [[HomeCheckInCardView alloc] init];
    [self.view addSubview:_checkInCard];
}
@end
```

## 长页面用 UITableView

超过 2 屏的内容必须用 UITableView（或 UICollectionView），不要用 UIScrollView + 手写约束。

每种 Cell 单独文件：
- `HomeProductCell.h/.m`
- `HomeKYCPromptCell.h/.m`
- `HomeBannerCell.h/.m`

## TabBar 约定

子页面 push 时自动隐藏 TabBar：
- `BaseViewController.init` 中默认 `hidesBottomBarWhenPushed = YES`
- 根控制器（Tab 直接容器）在自己的 init 中恢复 `NO`

## 导航栏

透明导航栏（融入页面背景）：
```objc
UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
[appearance configureWithTransparentBackground];
appearance.titleTextAttributes = @{NSForegroundColorAttributeName: kTextPrimaryColor};
```

## 工程构建

每个 Phase 结束必须跑：
```bash
cd <project>
xcodebuild -workspace <Proj>.xcworkspace -scheme <Proj> \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  build 2>&1 | grep -E "error:|BUILD"
```

必须看到 `** BUILD SUCCEEDED **`。

## 运行验证

```bash
xcrun simctl install <DEVICE_ID> <path-to-app>
xcrun simctl launch <DEVICE_ID> <bundle-id>
xcrun simctl io <DEVICE_ID> screenshot <out-path>
```

## Pod 配置

`Podfile`：
```ruby
platform :ios, '13.0'
target 'MyApp' do
  use_frameworks!
  pod 'Masonry'
  pod 'YYModel'
  pod 'SDWebImage'
  pod 'SVProgressHUD'
end
```

## 安全默认

### hidesBottomBarWhenPushed
- Base VC init 默认 `YES`
- 根 VC init 覆盖为 `NO`

### 状态栏
Base VC 覆盖：
```objc
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
```

### SF Symbol fallback
所有系统图标必须用 `systemImageNamed:` + fallback：
```objc
UIImage *img = [UIImage imageNamed:iconName];
if (!img) img = [UIImage systemImageNamed:iconName];
```
