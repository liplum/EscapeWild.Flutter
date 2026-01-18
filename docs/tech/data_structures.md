# 核心数据结构与序列化

本项目对数据结构有严格的区分，主要分为静态原型和动态实例。

## 1. 物品模型 (Item vs ItemStack)

* **Item (原型)**：单例对象，存储不随时间改变的数据。
* **ItemStack (实例)**：代表背包中的具体物品，存储动态数据（如 ID、当前质量、组件状态）。

### 伪代码实现

```typescript
class ItemStack implements JConvertible {
  readonly id: string;
  readonly meta: Item; // 指向静态原型
  mass: number;
  extraData: Map<string, any>; // 存储动态扩展数据

  constructor(meta: Item, mass?: number) {
    this.id = generateUuid();
    this.meta = meta;
    this.mass = mass ?? meta.baseMass;
  }

  toJson() {
    return {
      id: this.id,
      name: this.meta.name, // 序列化时只记录名称，反序列化时通过名称找回原型
      mass: this.mass,
      extra: this.extraData
    };
  }
}
```

## 2. 容器实现 (Container)

容器通过特殊的 `ContainerItemStack` 实现，它继承自 `ItemStack` 并包含一个内部物品引用。

```typescript
class ContainerItemStack extends ItemStack {
  innerItem: ItemStack | null;

  get totalMass(): number {
    return this.meta.baseMass + (this.innerItem?.mass ?? 0);
  }
}
```

## 3. 序列化策略

* **多态支持**：序列化结果包含 `typeName` 字段，反序列化器根据此字段实例化正确的类。
* **引用恢复**：对于静态内容（如 `Item`），序列化时只保存其唯一标识符（名称），加载时从 `Contents` 注册表中恢复引用。
* **深度递归**：支持嵌套结构的自动序列化（如背包 -> 容器 -> 内部物品）。
