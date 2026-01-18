# 技术架构概述

本文档描述了游戏的底层代码结构和技术实现模式。

## 核心技术栈模式

虽然项目使用特定的编程语言开发，但其核心逻辑遵循以下通用模式：

1. **响应式状态管理**：通过观察者模式（Observer Pattern）实现 UI 与底层数据的同步。
2. **混合 ECS 架构**：结合了面向对象和实体组件系统的优点，通过 Mixin 和组合实现功能扩展。
3. **强类型数据模型**：使用严格的接口定义和数据类，确保逻辑的健壮性。
4. **双向序列化**：所有核心对象都具备从 JSON 转换和转换为 JSON 的能力，支持深度嵌套对象的持久化。

## 模块划分

* **Core (核心层)**：定义了游戏的基础协议（Protocols）、基类和核心逻辑（如时间流逝、背包逻辑）。
* **Game (内容层)**：具体的游戏内容实现，包括物品定义、配方注册、关卡生成逻辑。
* **UI (表现层)**：负责将核心层的数据渲染为用户界面，并处理用户输入。
* **Design (设计系统)**：通用的 UI 组件库和主题定义。

## 伪代码示例：核心接口定义

```typescript
// 基础可序列化协议
interface JConvertible {
  typeName: string;
  toJson(): any;
}

// 核心组件定义
interface Component extends JConvertible {
  onPassTime(owner: any, delta: TimeDuration): Promise<void>;
}

// 具有组件能力的对象
interface ComponentHost<T extends Component> {
  components: Map<string, T[]>;
  addComp(comp: T): void;
  getComp<T>(type: string): T | null;
}
```
