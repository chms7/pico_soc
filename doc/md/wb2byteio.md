# wb2byteio

## 1 wishbone FSM

- **状态转换**：

<img src="./wb2byteio/wishboneFSM.png" alt="wishboneFSM" style="zoom: 25%;" />

- **输出**：
  - 通过状态编码 `wb_state` 输出 `o_ack` 。
  - 在有效时钟沿（延迟一拍），根据 `wb_state` 和 `i_adr` 进行：
    - `A` 的读取。（获取来自 `IO` 的输入）
    - `C` 的写入、读出。（配置 `IOBUF` 的方向）
    - `S` 的写入/读出。（驱动 `I` 输出）

## 2 IOBUF

- 通过 `generate` 例化 8 个 `IOBUF` ，与  `A` `C` `S` 等相连。

![image-20230804105246098](./wb2byteio/image-20230804105246098.png)

## 仿真验证

- 配置 `C` 为全输出

![image-20230804110028753](./wb2byteio/image-20230804110028753.png)

- 写入 `S` ，驱动至输出 `o_iobuf` 

![image-20230804110150296](./wb2byteio/image-20230804110150296.png)

- 配置 `C` 为全输入

![image-20230804110214038](./wb2byteio/image-20230804110214038.png)

- `I` 无驱动，`o_iobuf` 为高阻态

![image-20230804110318431](./wb2byteio/image-20230804110318431.png)

- 驱动 `I` ，`o_iobuf` 有效

![image-20230804110408798](./wb2byteio/image-20230804110408798.png)

- 配置 `C` 为高 4 位输入，低 4 位输出

![image-20230804110557153](./wb2byteio/image-20230804110557153.png)

- 高 4 位无驱动，低 4 位由 `S` 驱动

![image-20230804110708579](./wb2byteio/image-20230804110708579.png)

