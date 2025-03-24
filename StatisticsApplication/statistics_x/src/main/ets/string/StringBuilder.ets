export class StringBuilder {
  private value: string[];

  constructor() {
    this.value = [];
  }

  append(str: string | number): StringBuilder {
    this.value.push(String(str));
    return this;
  }


  toString(): string {
    return this.value.join('');
  }
}