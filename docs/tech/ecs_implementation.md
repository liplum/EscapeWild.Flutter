# 组件系统实现

本项目的组件系统（ECS）实现结合了强类型检查和动态组合。

## 组件基类 (Comp)

所有组件都继承自一个基础协议，该协议定义了组件的生命周期和序列化接口。

```typescript
abstract class ItemComponent implements JConvertible {
  abstract readonly typeName: string;

  // 当时间流逝时调用
  async onPassTime(stack: ItemStack, delta: Minutes): Promise<void> {}

  // 当物品合并时调用
  onMerge(from: ItemStack, to: ItemStack): void {}

  // 当物品拆分时调用
  onSplit(from: ItemStack, to: ItemStack): void {}
}
```

## 组件宿主 (CompMixin)

物品原型 `Item` 通过混入机制持有组件列表。

```typescript
class Item {
  private components: Map<string, ItemComponent[]> = new Map();

  addComp(comp: ItemComponent) {
    const list = this.components.get(comp.typeName) || [];
    list.push(comp);
    this.components.set(comp.typeName, list);
  }

  // 获取特定类型的第一个组件
  getFirstComp<T extends ItemComponent>(type: string): T | null {
    return (this.components.get(type)?.[0] as T) || null;
  }

  // 迭代所有组件
  *iterateComps(): IterableIterator<ItemComponent> {
    for (const list of this.components.values()) {
      yield* list;
    }
  }
}
```

## 核心组件示例

### 耐久度组件 (DurabilityComp)

管理物品的使用次数或寿命。

```typescript
class DurabilityComp extends ItemComponent {
  readonly typeName = "Durability";
  maxDurability: number;

  // 逻辑实现：当耐久度归零时从背包移除物品
  damage(stack: ItemStack, amount: number) {
    const current = stack.extraData.get("durability") || this.maxDurability;
    const next = Math.max(0, current - amount);
    stack.extraData.set("durability", next);
  }
}
```

### 属性修改组件 (ModifyAttrComp)

定义使用物品后对玩家属性的影响。

```typescript
class ModifyAttrComp extends ItemComponent {
  readonly typeName = "ModifyAttr";
  modifiers: Map<string, number>; // 如: { "hunger": 20, "health": -5 }
}
```
