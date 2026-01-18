# 游戏状态与持久化

游戏状态管理采用集中式单例模式，并支持完整的深度序列化以实现存档功能。

## 玩家单例 (Player)

`Player` 类是游戏运行时的核心状态机，它持有：

* **属性模型 (AttrModel)**：当前的生理指标。
* **背包 (Backpack)**：持有的所有物品。
* **位置 (Location)**：当前所处的地点引用。
* **关卡 (Level)**：当前关卡的逻辑控制器。

## 存档流程

存档过程是将整个 `Player` 对象及其关联的复杂对象树转换为 JSON 字符串的过程。

### 1. 序列化 (Save)

1. 调用 `player.toJson()`。
2. 递归调用 `backpack.toJson()`，进而调用每个 `itemStack.toJson()`。
3. 调用 `level.toJson()`，保存当前的路线状态和地点信息。
4. 将生成的 JSON 对象持久化到本地存储。

### 2. 反序列化 (Load)

1. 读取 JSON 字符串并解析为对象。
2. 通过 `Contents` 注册表恢复所有静态引用（如物品原型、地点定义）。
3. 重建对象树，确保 ID 和状态的一致性。
4. 通知 UI 层状态已更新。

## 伪代码示例：存档结构

```json
{
  "attrs": {
    "health": 85.0,
    "hunger": 40.0
  },
  "backpack": {
    "items": [
      {
        "name": "stone_axe",
        "id": "uuid-1",
        "extra": { "durability": 45 }
      },
      {
        "name": "water_bottle",
        "id": "uuid-2",
        "inner": { "name": "dirty_water", "mass": 500 }
      }
    ]
  },
  "level": {
    "type": "SubtropicsLevel",
    "seed": 12345,
    "currentLocationId": "forest_clearing_1"
  },
  "actionTimes": 152,
  "totalTimePassed": 1440
}
```

## 状态同步

项目使用响应式机制（如 `ChangeNotifier` 模式）。当底层数据（如玩家属性或背包内容）发生变化时，会自动触发 UI 的重新渲染，确保玩家看到的始终是最新的状态。
